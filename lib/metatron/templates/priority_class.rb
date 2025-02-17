# frozen_string_literal: true

module Metatron
  module Templates
    # Template for the  PriorityClass k8s resource
    class PriorityClass < Template
      include Concerns::Annotated

      attr_accessor :additional_labels, :description, :global_default, :value

      alias global_default? global_default
      alias globalDefault global_default

      def initialize(name)
        super
        @api_version = "scheduling.k8s.io/v1"
        @additional_labels = {}
        @description = nil
        @global_default = false
        @value = 0
      end

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: base_labels.merge(additional_labels)
          }.merge(formatted_annotations),
          description:,
          globalDefault:,
          value:
        }.compact
      end
    end
  end
end
