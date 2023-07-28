# frozen_string_literal: true

module Metatron
  module Templates
    # The ReplicaSet Kubernetes resource
    class ReplicaSet < Template
      include Concerns::Annotated
      include Concerns::PodProducer
      include Concerns::Namespaced

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
          }.merge(formatted_annotations).merge(formatted_namespace),
          spec: {
            replicas:,
            selector: {
              matchLabels: { "#{label_namespace}/name": name }.merge(additional_pod_labels)
            },
            template: {
              metadata: {
                labels: { "#{label_namespace}/name": name }.merge(additional_pod_labels)
              }.merge(formatted_pod_annotations),
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
