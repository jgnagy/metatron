# frozen_string_literal: true

module Metatron
  module Templates
    class GRPCRoute
      # Internal model for a GRPCRoute rule
      class Rule
        attr_accessor :backend_refs, :matches
        attr_reader :filters

        def initialize(backend_refs:, matches: nil)
          @backend_refs = backend_refs
          @matches = matches
          @filters = []
        end

        def add_filter(filter = nil, **attrs)
          @filters << if filter.is_a?(Filter)
                        filter
                      else
                        Filter.new(**attrs)
                      end
        end

        def render
          { backendRefs: backend_refs }
            .merge(matches ? { matches: } : {})
            .merge(filters.empty? ? {} : { filters: filters.map(&:render) })
        end
      end
    end
  end
end
