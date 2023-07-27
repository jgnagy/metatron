# frozen_string_literal: true

module Metatron
  module Templates
    module Concerns
      # Makes supporting namespaced resources easier
      module Namespaced
        def self.included(base)
          # base.extend ClassMethods
          base.class_eval do
            attr_accessor :namespace

            initializer :namespaced_initialize
          end
        end

        def namespaced_initialize
          @namespace = nil
        end

        def formatted_namespace
          if namespace
            { namespace: namespace.is_a?(Namespace) ? namespace.name : namespace }
          else
            {}
          end
        end
      end
    end
  end
end
