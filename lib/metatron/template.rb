# frozen_string_literal: true

module Metatron
  # Base class for templating Kubernetes resources
  class Template
    attr_accessor :api_version, :name, :additional_labels
    attr_reader :kind, :label_namespace

    class << self
      attr_writer :label_namespace

      def label_namespace
        @label_namespace ||= "metatron.therubyist.org"
      end
    end

    def initialize(name)
      @name = name
      @label_namespace = self.class.label_namespace
      @api_version = "v1"
      @kind = find_kind
      @additional_labels = {}
      run_initializers
    end

    alias apiVersion api_version

    def self.initializer(*args)
      @initializers ||= []
      @initializers += args
    end

    def self.initializers
      @initializers ||= []
    end

    def self.nearest_metatron_ancestor
      return self if metatron_template_class?

      ancestors.find { _1.respond_to?(:metatron_template_class?) && _1.metatron_template_class? }
    end

    def self.metatron_template_class?
      return true if name == "Metatron::Template"
      return false if name.start_with?("Metatron::Templates::Concerns")

      name.start_with?("Metatron::Templates::")
    end

    private

    def run_initializers
      self.class.nearest_metatron_ancestor.initializers.each { send(_1.to_sym) }
    end

    def find_kind = self.class.nearest_metatron_ancestor.name.split("::").last
  end
end
