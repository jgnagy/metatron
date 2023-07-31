# frozen_string_literal: true

module Metatron
  module Templates
    # Template for basic StatefulSet k8s resource
    class StatefulSet < Template
      include Concerns::Annotated
      include Concerns::PodProducer
      include Concerns::Namespaced

      attr_accessor :replicas, :service_name, :pod_management_policy

      def initialize(name, replicas: 1)
        super(name)
        @replicas = replicas
        @api_version = "apps/v1"
        @pod_management_policy = "OrderedReady"
        @service_name = name
      end

      alias enableServiceLinks enable_service_links
      alias podManagementPolicy pod_management_policy
      alias serviceName service_name

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
            serviceName:,
            updateStrategy: { type: "RollingUpdate",
                              rollingUpdate: { maxSurge: 2, maxUnavailable: 0 } },
            selector: {
              matchLabels: { "#{label_namespace}/name": name }.merge(additional_pod_labels)
            }
          }.merge(pod_template)
        }.merge(volume_claim_templates)
      end
    end
  end
end
