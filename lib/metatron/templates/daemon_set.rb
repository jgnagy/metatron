# frozen_string_literal: true

module Metatron
  module Templates
    # The DaemonSet Kubernetes resource
    class DaemonSet < Template
      include Concerns::Annotated
      include Concerns::Namespaced
      include Concerns::PodProducer

      attr_accessor :replicas, :additional_labels

      def initialize(name)
        super(name)
        @api_version = "apps/v1"
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
            selector: {
              matchLabels: { "#{label_namespace}/name": name }.merge(additional_pod_labels)
            }
          }.merge(pod_template)
        }
      end
    end
  end
end
