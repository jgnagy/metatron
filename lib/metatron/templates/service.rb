# frozen_string_literal: true

module Metatron
  module Templates
    # The Service Kubernetes resource
    class Service < Template
      include Concerns::Annotated
      include Concerns::Namespaced

      attr_accessor :type, :selector, :additional_labels, :ports,
                    :additional_selector_labels, :publish_not_ready_addresses,
                    :cluster_ip

      def initialize(name, port = nil)
        super(name)
        @type = "ClusterIP"
        @cluster_ip = nil
        @selector = base_labels
        @additional_labels = {}
        @additional_selector_labels = {}
        @publish_not_ready_addresses = false
        return unless port

        @ports = [
          {
            port: port.to_i,
            targetPort: port.to_i,
            protocol: "TCP",
            name:
          }
        ]
      end

      alias publishNotReadyAddresses publish_not_ready_addresses
      alias clusterIP cluster_ip

      def formatted_ports
        ports&.any? ? { ports: } : {}
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
            type:,
            selector: selector.merge(additional_selector_labels),
            publishNotReadyAddresses:,
            clusterIP:
          }.compact.merge(formatted_ports)
        }
      end
    end
  end
end
