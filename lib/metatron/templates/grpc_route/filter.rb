# frozen_string_literal: true

module Metatron
  module Templates
    class GRPCRoute
      # Internal model for a GRPCRoute filter.
      # The +type+ must be the canonical CamelCase name (e.g.
      # "RequestHeaderModifier", "ResponseHeaderModifier", "RequestMirror",
      # "ExtensionRef"). All remaining keyword arguments become the type-specific
      # configuration nested under the auto-derived camelCase key.
      #
      # Example:
      #   Filter.new(
      #     type: "RequestHeaderModifier",
      #     add: [{ name: "X-Custom-Header", value: "custom-value" }]
      #   )
      #   # => { type: "RequestHeaderModifier",
      #   #      requestHeaderModifier: { add: [{ ... }] } }
      class Filter
        attr_accessor :type, :config

        def initialize(type:, **config)
          @type = type
          @config = config
        end

        def render
          { type: }.merge(config.empty? ? {} : { type_key => config })
        end

        private

        def type_key
          # PascalCase → lowerCamelCase, handling acronym prefixes:
          #   "RequestHeaderModifier" → :requestHeaderModifier
          #   "ExtensionRef"          → :extensionRef
          type
            .sub(/\A([A-Z]+)(?=[A-Z][a-z])/, &:downcase)
            .sub(/\A[A-Z]/, &:downcase)
            .to_sym
        end
      end
    end
  end
end
