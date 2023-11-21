# frozen_string_literal: true

module Metatron
  # Base class for API services
  class Controller
    class << self
      def call(env)
        new(env).call
      end
    end

    attr_accessor :request_body

    def initialize(env)
      @env = env
      @request = Rack::Request.new(env)
    end

    def call
      begin
        if request&.content_type&.include?("json")
          body = request.body.read
          request.body.rewind if request.body.respond_to?(:rewind)

          self.request_body = JSON.parse(body) unless body.empty?
        end
      rescue JSON::ParserError => e
        return [400, {}, [{ error: "Request must be JSON: #{e.message}" }.to_json]]
      end

      _call
    end

    private

    attr_reader :request
  end
end
