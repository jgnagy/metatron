# frozen_string_literal: true

module Metatron
  module Templates
    # Template for basic StatefulSet k8s resource
    class StatefulSet < Template
      include Concerns::Annotated
      include Concerns::PodProducer

      attr_accessor :replicas, :pod_annotations, :service_name,
                    :pod_management_policy, :enable_service_links,
                    :additional_pod_labels

      def initialize(name, replicas: 1)
        super(name)
        @replicas = replicas
        @api_version = "apps/v1"
        @pod_annotations = {}
        @pod_management_policy = "OrderedReady"
        @additional_pod_labels = {}
        @enable_service_links = true
        @service_name = name
      end

      alias enableServiceLinks enable_service_links
      alias podManagementPolicy pod_management_policy
      alias serviceName service_name

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
            serviceName:,
            enableServiceLinks:,
            strategy: { type: "RollingUpdate", rollingUpdate: { maxSurge: 2, maxUnavailable: 0 } },
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
                    .merge(formatted_security_context)
                ] + additional_containers
              }.merge(formatted_volumes)
                .merge(formatted_affinity)
                .merge(formatted_tolerations)
            }
          }
        }
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
