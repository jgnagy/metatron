# frozen_string_literal: true

module Metatron
  module Templates
    # Template for TLSRoute k8s resource (Gateway API)
    class TLSRoute < Template
      include Concerns::Annotated
      include Concerns::Namespaced
      include Concerns::RouteResource

      attr_accessor :additional_labels
      attr_reader :hostnames, :rules

      def initialize(name)
        super
        @api_version = "gateway.networking.k8s.io/v1"
        @additional_labels = {}
        @hostnames = []
        @rules = []
      end

      def add_hostname(hostname)
        @hostnames << hostname
      end

      def add_rule(rule = nil, **attrs)
        @rules << if rule.is_a?(Rule)
                    rule
                  else
                    Rule.new(**attrs)
                  end
      end

      def formatted_hostnames
        hostnames.empty? ? {} : { hostnames: }
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
            .merge(formatted_hostnames)
            .merge(rules.empty? ? {} : { rules: rules.map(&:render) })
        }
      end
    end
  end
end
