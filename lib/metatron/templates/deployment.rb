# frozen_string_literal: true

module Metatron
  module Templates
    # The Deployment Kubernetes resource
    class Deployment < Template
      include Concerns::Annotated
      include Concerns::Namespaced
      include Concerns::PodProducer

      attr_accessor :replicas, :additional_labels, :strategy

      def initialize(name, replicas: 2)
        super(name)
        @api_version = "apps/v1"
        @replicas = replicas
      end

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: base_labels.merge(additional_labels)
          }.merge(formatted_annotations).merge(formatted_namespace),
          spec: {
            replicas:,
            strategy:,
            selector: {
              matchLabels: base_labels.merge(additional_pod_labels)
            }
          }.merge(pod_template).compact
        }
      end
    end
  end
end
