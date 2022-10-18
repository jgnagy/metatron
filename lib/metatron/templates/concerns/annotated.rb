# frozen_string_literal: true

module Metatron
  module Templates
    module Concerns
      # Makes supporting annotated resources easier
      module Annotated
        def self.included(base)
          # base.extend ClassMethods
          base.class_eval do
            attr_accessor :annotations

            initializer :annotated_initialize
          end
        end

        def annotated_initialize
          @annotations = {}
        end

        def formatted_annotations
          annotations && !annotations.empty? ? { annotations: } : {}
        end
      end
    end
  end
end
