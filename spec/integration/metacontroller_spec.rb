# frozen_string_literal: true

require_relative "integration_helper"

RSpec.describe "Metatron with a real Metacontroller", :integration do
  include IntegrationHelper

  describe "initial reconciliation" do
    before(:all) do
      @name = widget_name("smoke")
      apply_widget(@name, replicas: 2, config_value: "initial")
      wait_for_children(@name)
    end

    after(:all) do
      delete_widget(@name)
      wait_for_widget_deleted(@name)
    end

    it "creates one child of each configured kind" do
      kinds = children(@name).map { |resource| resource["kind"] }.sort
      expect(kinds).to eq(%w[ConfigMap Deployment Secret Service])
    end

    it "renders the Deployment from the parent spec" do
      deployment = child(@name, "Deployment")

      expect(deployment.dig("spec", "replicas")).to eq(2)
      expect(deployment.dig("spec", "template", "spec", "containers", 0, "image"))
        .to eq(default_image)
      expect(deployment.dig("metadata", "labels", "metatron.therubyist.org/name"))
        .to eq(@name)
      expect(deployment.dig("spec", "template", "metadata", "labels",
                            "app.kubernetes.io/component")).to eq("widget")
    end

    it "renders the Service selector and port" do
      service = child(@name, "Service")

      expect(service.dig("spec", "selector", "metatron.therubyist.org/name")).to eq(@name)
      expect(service.dig("spec", "selector", "app.kubernetes.io/component")).to eq("widget")
      expect(service.dig("spec", "ports", 0, "port")).to eq(80)
      expect(service.dig("spec", "ports", 0, "targetPort")).to eq(8080)
    end

    it "renders the ConfigMap data" do
      config_map = child(@name, "ConfigMap")

      expect(config_map.dig("data", "widget.properties")).to include("replicas=2")
      expect(config_map.dig("data", "widget.properties")).to include("configValue=initial")
    end

    it "renders a stable Secret" do
      secret = child(@name, "Secret")
      token = Base64.strict_decode64(secret.dig("data", "token"))

      expect(token).to match(/\A[0-9a-f]{64}\z/)
    end

    it "sets owner references on children" do
      owner = child(@name, "Deployment").dig("metadata", "ownerReferences").first

      expect(owner["kind"]).to eq("Widget")
      expect(owner["name"]).to eq(@name)
    end

    it "writes the sync status back to the parent" do
      wait_until(message: "parent status") do
        kubectl_json("get", "widget", @name, "-n", namespace).dig("status", "replicas") == 2
      end

      expect(kubectl_json("get", "widget", @name, "-n", namespace)
        .dig("status", "configValue")).to eq("initial")
    end
  end

  describe "updating the parent" do
    before(:all) do
      @name = widget_name("update")
      apply_widget(@name, replicas: 1, config_value: "before")
      wait_for_children(@name)
    end

    after(:all) do
      delete_widget(@name)
      wait_for_widget_deleted(@name)
    end

    it "propagates changes to the Deployment, ConfigMap, and status" do
      kubectl(
        "patch", "widget", @name, "-n", namespace,
        "--type=merge",
        "-p", '{"spec":{"replicas":3,"configValue":"after"}}'
      )

      wait_until(timeout: 120, message: "updated children") do
        deployment = child(@name, "Deployment")
        config_map = child(@name, "ConfigMap")

        deployment&.dig("spec", "replicas") == 3 &&
          config_map&.dig("data", "widget.properties")&.include?("configValue=after")
      end

      wait_until(timeout: 60, message: "updated parent status") do
        kubectl_json("get", "widget", @name, "-n", namespace).dig("status", "replicas") == 3
      end

      expect(child(@name, "ConfigMap").dig("data", "widget.properties"))
        .to include("configValue=after")
    end
  end

  describe "resync idempotency" do
    before(:all) do
      @name = widget_name("idempotent")
      apply_widget(@name, replicas: 1, config_value: "stable")
      wait_for_children(@name)
      wait_for_log("POST /sync -> 304", timeout: 90)
    end

    after(:all) do
      delete_widget(@name)
      wait_for_widget_deleted(@name)
    end

    it "short-circuits unchanged resyncs with a 304 ETag response" do
      expect(controller_logs).to include("POST /sync -> 304")
    end

    it "does not churn child resources across resyncs" do
      baseline = stable_identity
      sleep 11
      expect(stable_identity).to eq(baseline)
    end

    def stable_identity
      {
        "Deployment" => kubectl_json(
          "get", "deployment", @name, "-n", namespace
        ).dig("metadata", "generation"),
        "ConfigMap" => kubectl_json(
          "get", "configmap", "#{@name}-config", "-n", namespace
        ).dig("metadata", "resourceVersion"),
        "Secret" => kubectl_json(
          "get", "secret", "#{@name}-secret", "-n", namespace
        ).dig("metadata", "resourceVersion")
      }
    end
  end

  describe "finalization" do
    before(:all) do
      @name = widget_name("finalizer")
      apply_widget(@name, replicas: 1, config_value: "finalize")
      wait_for_children(@name)
    end

    after(:all) do
      delete_widget(@name)
    end

    it "calls finalize and garbage-collects children when the parent is deleted" do
      kubectl("delete", "widget", @name, "-n", namespace, "--wait=false")
      wait_for_widget_deleted(@name)

      wait_until(timeout: 120, message: "children of #{@name} to be garbage-collected") do
        children(@name).empty?
      end

      wait_for_log("finalize #{@name}", timeout: 60)
    end
  end

  describe "webhook authentication" do
    it "leaves /ping unauthenticated for probes" do
      with_port_forward do |port|
        response = Net::HTTP.start("127.0.0.1", port) { |http| http.get("/ping") }

        expect(response.code).to eq("200")
        expect(response.body).to eq({ status: "up" }.to_json)
      end
    end

    it "rejects hook calls without a token and accepts the shared bearer token" do
      body = {
        parent: {
          metadata: { name: "auth-check", namespace: namespace, uid: "auth-check-uid" },
          spec: { replicas: 1 }
        },
        children: {}
      }.to_json

      with_port_forward do |port|
        anonymous = post_json(port, "/widgets/sync", body)
        wrong_token = post_json(port, "/widgets/sync", body, token: "not-the-token")
        authorized = post_json(port, "/widgets/sync", body, token: auth_token)

        expect(anonymous.code).to eq("401")
        expect(anonymous["www-authenticate"]).to include("Bearer")
        expect(wrong_token.code).to eq("401")
        expect(authorized.code).to eq("200")
      end
    end
  end
end
