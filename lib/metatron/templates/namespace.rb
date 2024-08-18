# frozen_string_literal: true

module Metatron
  module Templates
    # Template for basic Namespace k8s resource
    class Namespace < Template
      include Concerns::Annotated

      attr_accessor :additional_labels

      def initialize(name)
        super
        @additional_labels = {}
      end

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: base_labels.merge(additional_labels)
          }.merge(formatted_annotations)
        }
      end
    end
  end
end
