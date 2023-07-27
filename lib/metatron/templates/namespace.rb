# frozen_string_literal: true

module Metatron
  module Templates
    # Template for basic Namespace k8s resource
    class Namespace < Template
      attr_accessor :additional_labels

      def initialize(name)
        super(name)
        @additional_labels = {}
      end

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: { "#{label_namespace}/name": name }.merge(additional_labels)
          }.merge(formatted_annotations)
        }
      end
    end
  end
end
