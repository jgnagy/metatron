# frozen_string_literal: true

require "json" unless defined? JSON # allow for JSON to be loaded elsewhere

module Metatron
  # Base class for API services
  class Controller
    class << self
      def call(env)
        new(env).call
      end
    end

    attr_accessor :params

    def initialize(env)
      @env = env
      @request = Rack::Request.new(env)
    end

    def call
      begin
        parse_params
      rescue JSON::ParserError => e
        return [400, {}, [{ error: "Request must be JSON: #{e.message}" }.to_json]]
      end

      begin
        _call
      rescue StandardError, NotImplementedError => e
        log_exception(e)
        Problem.response(
          status: 500,
          title: "Internal Server Error",
          detail: "The controller failed to handle the request."
        )
      end
    end

    private

    attr_reader :request

    def parse_params
      return unless request&.content_type&.include?("json")

      body = request.body.read
      request.body.rewind if request.body.respond_to?(:rewind)

      self.params = JSON.parse(body) unless body.empty?
    end

    # Record the failure for the operator without leaking it to the caller.
    def log_exception(error)
      Metatron.logger&.error(
        "Metatron controller raised #{error.class}: #{error.message}\n" \
        "#{Array(error.backtrace).join("\n")}"
      )
    end
  end
end
