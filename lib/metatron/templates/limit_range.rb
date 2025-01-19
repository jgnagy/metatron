# frozen_string_literal: true

module Metatron
  module Templates
    # The LimitRange Kubernetes resource
    class LimitRange < Template
      # Limit is an internal class used to represent the limits in a LimitRange resource,
      # and to provide a consistent interface for rendering them. It is not intended to be
      # used outside of this class. Eventually, it may be used to provide validation for
      # the limits.
      class Limit
        attr_accessor :type, :default, :default_request, :max, :max_limit_request_ratio, :min

        alias defaultRequest default_request
        alias maxLimitRequestRatio max_limit_request_ratio

        class << self
          def to_limit(limit)
            limit.is_a?(Limit) ? limit : new(**limit)
          end
        end

        def initialize(type:, default: nil, default_request: nil, max: nil,
                       max_limit_request_ratio: nil, min: nil)
          @type = type
          @default = default
          @default_request = default_request
          @max = max
          @max_limit_request_ratio = max_limit_request_ratio
          @min = min
        end

        def render
          {
            type:,
            default:,
            defaultRequest:,
            max:,
            maxLimitRequestRatio:,
            min:
          }.compact
        end
      end

      include Concerns::Annotated
      include Concerns::Namespaced

      attr_accessor :limits

      def initialize(name, limits = [])
        super(name)
        @limits = limits
      end

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: base_labels.merge(additional_labels)
          }.merge(formatted_annotations).merge(formatted_namespace),
          spec: formatted_limits
        }.compact
      end

      private

      def formatted_limits
        return {} if limits.empty?

        { limits: limits.map { Limit.to_limit(_1).render } }
      end
    end
  end
end
