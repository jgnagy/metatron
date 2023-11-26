# frozen_string_literal: true

module Metatron
  module Templates
    # https://kubernetes.io/docs/concepts/services-networking/network-policies/
    class NetworkPolicy < Template
      include Concerns::Annotated
      include Concerns::Namespaced

      attr_accessor :pod_selector, :ingress, :egress

      alias podSelector pod_selector

      def initialize(name)
        super(name)
        @pod_selector = pod_selector
        @ingress = ingress
        @egress = egress
      end

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            labels: base_labels.merge(additional_labels),
            name:
          }.merge(formatted_annotations).merge(formatted_namespace),
          spec: {
            podSelector:
          }.merge(ingress ? { ingress: } : {}).merge(egress ? { egress: } : {})
        }
      end
    end
  end
end
