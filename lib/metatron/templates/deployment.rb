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
            }
          }.merge(pod_template)
        }
      end
    end
  end
end
