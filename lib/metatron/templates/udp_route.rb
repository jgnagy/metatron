# frozen_string_literal: true

module Metatron
  module Templates
    # Template for UDPRoute k8s resource (Gateway API)
    class UDPRoute < Template
      include Concerns::Annotated
      include Concerns::Namespaced
      include Concerns::RouteResource

      attr_accessor :additional_labels
      attr_reader :rules

      def initialize(name)
        super
        @api_version = "gateway.networking.k8s.io/v1alpha2"
        @additional_labels = {}
        @rules = []
      end

      def add_rule(rule = nil, **attrs)
        @rules << if rule.is_a?(Rule)
                    rule
                  else
                    Rule.new(**attrs)
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
          spec: formatted_parent_refs
            .merge(rules.empty? ? {} : { rules: rules.map(&:render) })
        }
      end
    end
  end
end
