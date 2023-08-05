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
            labels: { "#{label_namespace}/name": name }.merge(additional_labels)
          }.merge(formatted_annotations).compact,
          aggregationRule:,
          rules:
        }.compact
      end
    end
  end
end
