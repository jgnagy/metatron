# frozen_string_literal: true

module Metatron
  # Base class for templating Kubernetes resources
  class Template
    attr_accessor :api_version, :name, :additional_labels
    attr_reader :kind
    attr_writer :base_labels

    class << self
      attr_writer :label_namespace

      def label_namespace
        @label_namespace ||= "metatron.therubyist.org"
      end

      def initializer(*args)
        @initializers ||= []
        @initializers += args
      end

      def initializers
        @initializers ||= []
      end

      def nearest_metatron_ancestor
        return self if metatron_template_class?

        ancestors.find { _1.respond_to?(:metatron_template_class?) && _1.metatron_template_class? }
      end

      def metatron_template_class?
        return true if name == "Metatron::Template"
        return false if name.start_with?("Metatron::Templates::Concerns")

        name.start_with?("Metatron::Templates::")
      end
    end

    def initialize(name)
      @name = name
      @api_version = "v1"
      @kind = find_kind
      @additional_labels = {}
      run_initializers
    end

    alias apiVersion api_version

    def base_labels
      @base_labels || { "#{label_namespace}/name": name }
    end

    private

    # defers to the nearest metatron ancestor to determine the label namespace
    def label_namespace = self.class.label_namespace

    def run_initializers
      self.class.nearest_metatron_ancestor.initializers.each { send(_1.to_sym) }
    end

    def find_kind = self.class.nearest_metatron_ancestor.name.split("::").last
  end
end
