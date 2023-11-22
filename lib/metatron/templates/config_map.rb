# frozen_string_literal: true

module Metatron
  module Templates
    # The ConfigMap Kubernetes resource
    class ConfigMap < Template
      include Concerns::Annotated
      include Concerns::Namespaced

      attr_accessor :additional_labels, :immutable, :data

      def initialize(name, data = {})
        super(name)
        @data = data
        @additional_labels = {}
      end

      def immutable? = !!@immutable

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: base_labels.merge(additional_labels)
          }.merge(formatted_annotations).merge(formatted_namespace).compact,
          data:,
          immutable:
        }.compact
      end
    end
  end
end
