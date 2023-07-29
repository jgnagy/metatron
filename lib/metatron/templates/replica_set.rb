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
            }
          }.merge(pod_template)
        }
      end
    end
  end
end
