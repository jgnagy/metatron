# frozen_string_literal: true

module Metatron
  module Templates
    # The Secret Kubernetes resource
    class Secret < Template
      include Concerns::Annotated
      include Concerns::Namespaced

      attr_accessor :additional_labels, :type, :data

      def initialize(name, data = {})
        super(name)
        @data = data
        @additional_labels = {}
        @type = "Opaque"
      end

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: base_labels.merge(additional_labels)
          }.merge(formatted_annotations).merge(formatted_namespace).compact,
          type:,
          stringData: data
        }.compact
      end
    end
  end
end
