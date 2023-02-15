# frozen_string_literal: true

module Metatron
  module Templates
    # The ReplicaSet Kubernetes resource
    class ReplicaSet < Template
      include Concerns::Annotated
      include Concerns::PodProducer

      attr_accessor :replicas, :pod_annotations,
                    :additional_labels, :additional_pod_labels

      def initialize(name, replicas: 2)
        super(name)
        @api_version = "apps/v1"
        @kind = "ReplicaSet"
        @replicas = replicas
        @pod_annotations = {}
        @additional_pod_labels = {}
      end

      def formatted_pod_annotations
        pod_annotations && !pod_annotations.empty? ? { annotations: pod_annotations } : {}
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
            selector: {
              matchLabels: { "#{label_namespace}/name": name }.merge(additional_pod_labels)
            },
            template: {
              metadata: {
                labels: { "#{label_namespace}/name": name }.merge(additional_pod_labels)
              }.merge(formatted_pod_annotations),
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
          }
        }
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
