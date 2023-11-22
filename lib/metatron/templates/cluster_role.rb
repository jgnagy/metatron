# frozen_string_literal: true

module Metatron
  module Templates
    # Template for basic ClusterRole k8s resource
    class ClusterRole < Template
      include Concerns::Annotated

      attr_accessor :rules, :aggregation_rule

      alias aggregationRule aggregation_rule

      def initialize(name)
        super(name)
        @api_version = "rbac.authorization.k8s.io/v1"
        @rules = []
      end

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: base_labels.merge(additional_labels)
          }.merge(formatted_annotations).compact,
          aggregationRule:,
          rules: formatted_rules
        }.compact
      end

      def formatted_rules = rules.map { _1.respond_to?(:render) ? _1.render : _1 }
    end
  end
end
