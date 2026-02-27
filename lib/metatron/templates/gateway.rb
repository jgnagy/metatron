# frozen_string_literal: true

module Metatron
  module Templates
    # Template for Gateway k8s resource (Gateway API)
    class Gateway < Template
      include Concerns::Annotated
      include Concerns::Namespaced

      attr_accessor :gateway_class_name, :additional_labels
      attr_reader :listeners

      def initialize(name, gateway_class_name:)
        super(name)
        @gateway_class_name = gateway_class_name
        @api_version = "gateway.networking.k8s.io/v1"
        @additional_labels = {}
        @listeners = []
      end

      def add_listener(listener = nil, **attrs)
        @listeners << if listener.is_a?(Listener)
                        listener
                      else
                        Listener.new(attrs.delete(:name), **attrs)
                      end
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
            gatewayClassName: gateway_class_name,
            listeners: listeners.map(&:render)
          }
        }
      end
    end
  end
end
