# frozen_string_literal: true

module Metatron
  module Templates
    # The Secret Kubernetes resource
    class Secret < Template
      include Concerns::Annotated
      include Concerns::Namespaced

      attr_accessor :additional_labels, :type, :data, :string_data

      alias stringData string_data

      def initialize(name, provided_string_data = nil, string_data: nil, data: nil)
        super(name)
        @string_data = string_data || provided_string_data
        @data = data
        @additional_labels = {}
        @type = "Opaque"
      end

      def formatted_data
        data_hash = {}

        # Only include one of data or string_data, preferring data if both are present
        return data_hash unless data || string_data

        # If string_data is provided, it should be a hash of string values
        # and will be base64 encoded
        if string_data
          data_hash[:data] = string_data.transform_values do |value|
            Base64.strict_encode64(value.to_s).gsub("\n", "")
          end
        end

        # If data is provided, it should be a hash of base64 encoded values
        data_hash[:data] = data if data

        data_hash
      end

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: base_labels.merge(additional_labels)
          }.merge(formatted_annotations).merge(formatted_namespace).compact,
          type:
        }.compact.merge(formatted_data).compact
      end
    end
  end
end
