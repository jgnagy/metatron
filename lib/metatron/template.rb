# frozen_string_literal: true

module Metatron
  # Base class for templating Kubernetes resources
  class Template
    attr_accessor :api_version, :name
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
      @kind = self.class.name.split("::").last
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

    private

    def run_initializers
      self.class.initializers.each { |initializer| send(initializer.to_sym) }
    end
  end
end
