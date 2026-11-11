# frozen_string_literal: true

require "base64"
require "json"
require "net/http"
require "open3"
require "securerandom"
require "socket"

# Helpers for the cluster-backed integration suite. These specs expect a
# fixture controller and CRD already installed by `script/integration`.
module IntegrationHelper
  NAMESPACE = ENV.fetch("METATRON_IT_NAMESPACE", "metatron-integration")
  AUTH_TOKEN = ENV.fetch("METATRON_IT_AUTH_TOKEN", "integration-secret-token")
  RUN_ID = ENV.fetch("METATRON_IT_RUN_ID", SecureRandom.hex(4)).gsub(/[^a-z0-9-]/, "-")

  DEFAULT_IMAGE = "registry.k8s.io/pause:3.9"

  # RSpec resolves unqualified constants lexically, not through included
  # modules, so expose the values as methods instead.
  def namespace = NAMESPACE
  def default_image = DEFAULT_IMAGE
  def auth_token = AUTH_TOKEN

  def kubectl(*args, stdin_data: nil, allow_failure: false)
    command = ["kubectl", *args]
    stdout, stderr, status = Open3.capture3(*command, stdin_data: stdin_data.to_s)

    unless status.success? || allow_failure
      raise "kubectl #{args.join(" ")} failed (#{status.exitstatus}):\n#{stderr}\n#{stdout}"
    end

    [stdout, stderr, status]
  end

  def kubectl_json(*args)
    JSON.parse(kubectl(*args, "-o", "json").first)
  end

  def apply_yaml(yaml)
    kubectl("apply", "-f", "-", stdin_data: yaml)
  end

  def wait_until(timeout: 120, interval: 1, message: "condition")
    deadline = Time.now + timeout
    last_error = nil

    loop do
      begin
        result = yield
        return result if result
      rescue StandardError => e
        last_error = e
      end

      if Time.now > deadline
        detail = last_error ? ": #{last_error.message}" : ""
        raise "timed out waiting for #{message}#{detail}"
      end

      sleep interval
    end
  end

  def widget_name(suffix)
    "it-#{RUN_ID}-#{suffix}"
  end

  def widget_manifest(name, replicas: 2, image: DEFAULT_IMAGE, config_value: "initial")
    <<~YAML
      apiVersion: metatron.therubyist.org/v1
      kind: Widget
      metadata:
        name: #{name}
        namespace: #{NAMESPACE}
      spec:
        replicas: #{replicas}
        image: #{image}
        configValue: #{config_value}
    YAML
  end

  def apply_widget(name, **options)
    apply_yaml(widget_manifest(name, **options))
  end

  def delete_widget(name)
    kubectl(
      "delete", "widget", name, "-n", NAMESPACE,
      "--ignore-not-found", "--wait=false",
      allow_failure: true
    )
  end

  def wait_for_widget_deleted(name, timeout: 120)
    wait_until(timeout: timeout, message: "widget #{name} to be deleted") do
      output = kubectl(
        "get", "widget", name, "-n", NAMESPACE, "-o", "name",
        allow_failure: true
      ).first
      output.strip.empty?
    end
  end

  def children(name)
    kubectl_json(
      "get", "deployments,services,configmaps,secrets",
      "-n", NAMESPACE,
      "-l", "metatron.therubyist.org/parent=#{name}"
    ).fetch("items")
  end

  def wait_for_children(name, timeout: 120)
    wait_until(timeout: timeout, message: "children for #{name}") do
      kinds = children(name).map { |child| child["kind"] }
      (["Deployment", "Service", "ConfigMap", "Secret"] - kinds).empty?
    end
  end

  def child(name, kind)
    children(name).find { |resource| resource["kind"] == kind }
  end

  def controller_logs(tail: 500)
    kubectl(
      "logs", "-n", NAMESPACE, "-l", "app=widget-controller",
      "--tail=#{tail}", allow_failure: true
    ).first
  end

  def wait_for_log(text, timeout: 60)
    wait_until(timeout: timeout, message: "controller log containing #{text.inspect}") do
      controller_logs.include?(text)
    end
  end

  def free_port
    server = TCPServer.new("127.0.0.1", 0)
    server.addr[1]
  ensure
    server&.close
  end

  def with_port_forward
    port = free_port
    pid = Process.spawn(
      "kubectl", "-n", NAMESPACE, "port-forward", "svc/widget-controller", "#{port}:9292",
      out: File::NULL, err: File::NULL, pgroup: true
    )

    wait_until(timeout: 30, interval: 0.25, message: "port-forward on #{port}") do
      TCPSocket.new("127.0.0.1", port).close
      true
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
      false
    end

    yield port
  ensure
    if pid
      begin
        Process.kill("TERM", -Process.getpgid(pid))
      rescue Errno::ESRCH
        nil
      end
      begin
        Process.wait(pid)
      rescue Errno::ECHILD
        nil
      end
    end
  end

  def post_json(port, path, body, token: nil)
    request = Net::HTTP::Post.new(path, "Content-Type" => "application/json")
    request["Authorization"] = "Bearer #{token}" if token
    request.body = body

    Net::HTTP.start("127.0.0.1", port) { |http| http.request(request) }
  end
end
