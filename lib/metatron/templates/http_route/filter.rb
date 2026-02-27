# frozen_string_literal: true

module Metatron
  module Templates
    class HTTPRoute
      # Internal model for an HTTPRoute filter.
      # The +type+ must be the canonical CamelCase name (e.g. "URLRewrite",
      # "RequestHeaderModifier"). All remaining keyword arguments become the
      # type-specific configuration nested under the auto-derived camelCase key.
      #
      # Example:
      #   Filter.new(
      #     type: "URLRewrite",
      #     hostname: "example.net",
      #     path: { type: "ReplacePrefixMatch", replacePrefixMatch: "/new-prefix" }
      #   )
      #   # => { type: "URLRewrite", urlRewrite: { hostname: "example.net", path: { ... } } }
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
          #   "URLRewrite"             → :urlRewrite
          #   "RequestHeaderModifier"  → :requestHeaderModifier
          type
            .sub(/\A([A-Z]+)(?=[A-Z][a-z])/, &:downcase)
            .sub(/\A[A-Z]/, &:downcase)
            .to_sym
        end
      end
    end
  end
end
