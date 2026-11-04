# frozen_string_literal: true

require "stringio"

module Metatron
  # Rack middleware shipped with Metatron.
  module Middleware
    # Rejects request bodies larger than a configurable cap.
    #
    # The cap is enforced twice: up front from the `Content-Length` header
    # (cheap, and catches the common case without reading anything), and again
    # while reading the body, so that a missing or understated
    # `Content-Length` cannot be used to exhaust memory. The body is buffered
    # up to the cap and handed to the application as a rewound stream.
    #
    # @example
    #   use Metatron::Middleware::BodyLimit, max_bytes: 1_048_576
    class BodyLimit
      # Default cap on request body size: 1 MiB, which is generous for
      # Metacontroller sync payloads.
      DEFAULT_MAX_BYTES = 1024 * 1024

      # Environment variable consulted when no limit is passed explicitly.
      MAX_BYTES_ENV_VAR = "METATRON_MAX_REQUEST_BODY_BYTES"

      attr_reader :app

      # @param app [#call] the Rack application to protect
      # @param max_bytes [Integer, nil] the cap; falls back to the environment
      # @param env_var [String] the environment variable to read the cap from
      def initialize(app, max_bytes: nil, env_var: MAX_BYTES_ENV_VAR)
        @app = app
        @max_bytes = max_bytes
        @env_var = env_var
      end

      def call(env)
        limit = max_bytes

        length = env["CONTENT_LENGTH"]
        return payload_too_large(limit) if length && length.to_i > limit

        input = env["rack.input"]
        return app.call(env) if input.nil?

        body = read_capped(input, limit)
        return payload_too_large(limit) if body.nil?

        env["rack.input"] = StringIO.new(body).tap(&:binmode)
        app.call(env)
      end

      private

      # The maximum number of bytes accepted in a request body.
      def max_bytes
        return @max_bytes unless @max_bytes.nil?

        configured = ENV.fetch(@env_var, nil)
        return DEFAULT_MAX_BYTES if configured.nil? || configured.empty?

        configured.to_i
      end

      # Read at most `limit` bytes from the input stream.
      #
      # @return [String, nil] the body, or nil when it is larger than the limit
      def read_capped(input, limit)
        chunk = input.read(limit + 1)
        chunk = "" if chunk.nil?
        return nil if chunk.bytesize > limit

        chunk
      end

      def payload_too_large(limit)
        Problem.response(
          status: 413,
          title: "Payload Too Large",
          detail: "Request bodies may not exceed #{limit} bytes."
        )
      end
    end
  end
end
