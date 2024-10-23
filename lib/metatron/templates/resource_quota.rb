# frozen_string_literal: true

module Metatron
  module Templates
    # Template for basic Role k8s resource
    class ResourceQuota < Template
      include Concerns::Annotated
      include Concerns::Namespaced

      attr_accessor :additional_labels, :spec

      def initialize(name)
        super
        @additional_labels = {}
        @spec = {}
      end

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: base_labels.merge(additional_labels)
          }.merge(formatted_annotations).merge(formatted_namespace).compact
        }.merge(formatted_spec)
      end

      def formatted_spec = (@spec || {}).empty? ? {} : { spec: }
    end
  end
end
