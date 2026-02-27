# frozen_string_literal: true

module Metatron
  module Templates
    class TLSRoute
      # Internal model for a TLSRoute rule
      class Rule
        attr_accessor :backend_refs

        def initialize(backend_refs:)
          @backend_refs = backend_refs
        end

        def render
          { backendRefs: backend_refs }
        end
      end
    end
  end
end
