# frozen_string_literal: true

module Metatron
  module Templates
    # Template for basic StatefulSet k8s resource
    class StatefulSet < Template
      include Concerns::Annotated
      include Concerns::PodProducer
      include Concerns::Namespaced

      attr_accessor :replicas, :service_name, :pod_management_policy, :update_strategy

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
      alias strategy update_strategy
      alias updateStrategy update_strategy

      def render # rubocop:disable Metrics/AbcSize
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
            updateStrategy:,
            selector: {
              matchLabels: { "#{label_namespace}/name": name }.merge(additional_pod_labels)
            }
          }.merge(pod_template).merge(volume_claim_templates).compact
        }
      end
    end
  end
end
