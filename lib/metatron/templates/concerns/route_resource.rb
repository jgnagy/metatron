# frozen_string_literal: true

module Metatron
  module Templates
    module Concerns
      # Provides common parent reference functionality for Gateway API route resources
      module RouteResource
        def self.included(base)
          base.class_eval do
            attr_reader :parent_refs

            initializer :route_resource_initialize
          end
        end

        def route_resource_initialize
          @parent_refs = []
        end

        def add_parent_ref(name:, namespace: nil, kind: "Gateway", section_name: nil, port: nil)
          ref = { name:, kind: }
          ref[:namespace] = namespace if namespace
          ref[:sectionName] = section_name if section_name
          ref[:port] = port if port
          @parent_refs << ref
        end

        def formatted_parent_refs
          parent_refs.empty? ? {} : { parentRefs: parent_refs }
        end
      end
    end
  end
end
