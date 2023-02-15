# frozen_string_literal: true

module Metatron
  module Templates
    # Template for basic Pod k8s resource
    class Pod < Template
      include Concerns::Annotated
      include Concerns::PodProducer

      def initialize(name)
        super(name)
        @kind = "Pod"
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            labels: { "#{label_namespace}/name": name }.merge(additional_labels),
            name:
          }.merge(formatted_annotations),
          spec: {
            terminationGracePeriodSeconds:,
            containers: [
              {
                name: "app",
                image:,
                imagePullPolicy:,
                stdin: true,
                tty: true,
                resources: { limits: resource_limits, requests: resource_requests }
              }.merge(probes)
                .merge(formatted_environment)
                .merge(formatted_envfrom)
                .merge(formatted_ports)
                .merge(formatted_volume_mounts)
                .merge(formatted_container_security_context)
            ] + additional_containers
          }.merge(formatted_volumes).merge(formatted_security_context)
        }
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
