# frozen_string_literal: true

module Metatron
  module Templates
    # The Service Kubernetes resource
    class Service < Template
      include Concerns::Annotated
      include Concerns::Namespaced

      attr_accessor :type, :selector, :additional_labels, :ports,
                    :additional_selector_labels, :publish_not_ready_addresses

      def initialize(name, port = nil)
        super(name)
        @type = "ClusterIP"
        @selector = { "#{label_namespace}/name": name }
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

      def formatted_ports
        ports&.any? ? { ports: } : {}
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
            type:,
            selector: selector.merge(additional_selector_labels),
            publishNotReadyAddresses:
          }.merge(formatted_ports)
        }
      end
    end
  end
end
