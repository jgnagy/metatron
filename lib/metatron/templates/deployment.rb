# frozen_string_literal: true

module Metatron
  module Templates
    # The Deployment Kubernetes resource
    class Deployment < Template
      include Concerns::Annotated
      include Concerns::Namespaced
      include Concerns::PodProducer

      attr_accessor :replicas, :additional_labels

      def initialize(name, replicas: 2)
        super(name)
        @api_version = "apps/v1"
        @replicas = replicas
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: { "#{label_namespace}/name": name }.merge(additional_labels)
          }.merge(formatted_annotations),
          spec: {
            replicas:,
            strategy: { type: "RollingUpdate", rollingUpdate: { maxSurge: 2, maxUnavailable: 0 } },
            selector: {
              matchLabels: { "#{label_namespace}/name": name }.merge(additional_pod_labels)
            },
            template: {
              metadata: {
                labels: { "#{label_namespace}/name": name }.merge(additional_pod_labels)
              }.merge(formatted_pod_annotations).merge(formatted_namespace),
              spec: {
                terminationGracePeriodSeconds:,
                containers: containers.map(&:render),
                init_containers: init_containers.any? ? init_containers.map(&:render) : nil
              }.merge(formatted_volumes)
                .merge(formatted_security_context)
                .merge(formatted_tolerations)
                .compact
            }
          }
        }
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
