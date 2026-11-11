# frozen_string_literal: true

require "digest"
require "json"

module IntegrationController
  # A deliberately small CompositeController used to exercise Metatron against
  # a real Metacontroller installation. It produces one of each child type the
  # gem templates most often: a ConfigMap, a Secret, a Deployment, and a
  # Service.
  class WidgetController < Metatron::CompositeController
    DEFAULT_IMAGE = "registry.k8s.io/pause:3.9"

    def sync # rubocop:disable Metrics/AbcSize
      parent = params.fetch("parent")
      metadata = parent.fetch("metadata")
      spec = parent.fetch("spec", {})
      name = metadata.fetch("name")
      namespace = metadata["namespace"]
      replicas = Integer(spec.fetch("replicas", 1))
      image = spec["image"] || DEFAULT_IMAGE
      config_value = spec["configValue"] || "default"
      parent_labels = { "metatron.therubyist.org/parent" => name }

      config_map = Metatron::Templates::ConfigMap.new(
        "#{name}-config",
        {
          "widget.properties" => "replicas=#{replicas}\nimage=#{image}\nconfigValue=#{config_value}\n"
        }
      )
      config_map.namespace = namespace
      config_map.additional_labels = parent_labels

      secret = Metatron::Templates::Secret.new(
        "#{name}-secret",
        { "token" => Digest::SHA256.hexdigest("#{name}:#{metadata["uid"]}") }
      )
      secret.namespace = namespace
      secret.additional_labels = parent_labels

      deployment = Metatron::Templates::Deployment.new(name, replicas: replicas)
      deployment.namespace = namespace
      deployment.additional_labels = parent_labels
      deployment.additional_pod_labels = { "app.kubernetes.io/component" => "widget" }
      deployment.containers << build_container(image, config_value)

      service = Metatron::Templates::Service.new(name, 80)
      service.namespace = namespace
      service.additional_labels = parent_labels
      service.additional_selector_labels = deployment.additional_pod_labels
      service.ports.first[:targetPort] = 8080

      {
        status: { replicas: replicas, configValue: config_value },
        children: [config_map, secret, deployment, service]
      }
    end

    def finalize
      name = params.dig("parent", "metadata", "name")
      Metatron.logger.info("finalize #{name}")
      { status: {}, finalized: true }
    end

    # A stable ETag lets Metacontroller short-circuit unchanged resyncs with a
    # 304 instead of re-applying identical children. The integration suite
    # asserts that this path is taken at least once.
    def calculate_sync_etag
      children = sync.fetch(:children).map do |child|
        child.respond_to?(:render) ? child.render : child
      end
      Digest::SHA256.hexdigest(JSON.generate(children))
    end

    private

    def build_container(image, config_value)
      container = Metatron::Templates::Container.new("widget", image)
      container.ports = [{ name: "http", containerPort: 8080 }]
      container.env = { "WIDGET_CONFIG" => config_value }
      container
    end
  end
end
