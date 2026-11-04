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
      rescue Metatron::PayloadTooLarge
        return Metatron::Problem.response(
          status: 413,
          title: "Payload Too Large",
          detail: "Request body exceeds the maximum allowed size"
        )
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

      body = read_bounded_body

      self.params = JSON.parse(body) unless body.empty?
    end

    # Read the request body, enforcing the configured size cap.
    # Raises PayloadTooLarge when the body exceeds the limit; the
    # controller's rescue converts it to a 413 problem document.
    def read_bounded_body
      limit = Metatron.max_body_bytes
      raise Metatron::PayloadTooLarge if request.content_length.to_i > limit

      # Read at most one byte more than the limit so an oversized
      # chunked body (no Content-Length) is still caught.
      body = request.body.read(limit + 1) || ""
      request.body.rewind if request.body.respond_to?(:rewind)
      raise Metatron::PayloadTooLarge if body.bytesize > limit

      body
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
