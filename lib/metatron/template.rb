# frozen_string_literal: true

module Metatron
  # Base class for templating Kubernetes resources
  class Template
    attr_accessor :api_version, :label_namespace, :name
    attr_reader :kind

    def initialize(name)
      @name = name
      @label_namespace = "metatron.therubyist.org"
      @api_version = "v1"
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
