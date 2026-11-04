# frozen_string_literal: true

require "rack/utils"

module Metatron
  # Rack middleware shipped with Metatron.
  module Middleware
    # Requires a shared secret to be presented as a Bearer token before the
    # request reaches the controller.
    #
    # The middleware is opt-in: it enforces nothing until a secret is
    # configured, either by passing `secret:` to the constructor or by setting
    # the `METATRON_AUTH_SECRET` environment variable. With no secret
    # configured, requests are passed straight through, so existing
    # applications behave exactly as they did before.
    #
    # Metacontroller can send the matching credential via the hook spec's
    # `webhook.authorization.secretRef`, which points at a Kubernetes Secret
    # whose value is shared with this middleware.
    #
    # @example
    #   use Metatron::Middleware::Auth, secret: ENV["METATRON_AUTH_SECRET"]
    #
    # @see https://metacontroller.github.io/metacontroller/api/compositecontroller.html
    class Auth
      # Environment variable consulted when no secret is passed explicitly.
      SECRET_ENV_VAR = "METATRON_AUTH_SECRET"

      # The only authentication scheme understood by this middleware.
      SCHEME = "Bearer"

      # Rack environment key holding the `Authorization` header.
      AUTHORIZATION_HEADER = "HTTP_AUTHORIZATION"

      # Challenge sent with unauthorized responses.
      CHALLENGE = "Bearer realm=\"metatron\""

      attr_reader :app

      # @param app [#call] the Rack application to protect
      # @param secret [String, nil] the shared secret; falls back to the environment
      # @param env_var [String] the environment variable to read the secret from
      def initialize(app, secret: nil, env_var: SECRET_ENV_VAR)
        @app = app
        @secret = secret
        @env_var = env_var
      end

      def call(env)
        expected = configured_secret
        return app.call(env) if expected.nil?

        presented = bearer_token(env)
        return unauthorized if presented.nil?
        return unauthorized unless secure_compare?(presented, expected)

        app.call(env)
      end

      private

      # The secret to check against, or nil when authentication is disabled.
      def configured_secret
        secret = @secret || ENV.fetch(@env_var, nil)
        return nil if secret.nil?

        secret = secret.to_s
        secret.empty? ? nil : secret
      end

      # Extract the token from an `Authorization: Bearer <token>` header.
      #
      # @return [String, nil] the token, or nil when no usable token is present
      def bearer_token(env)
        header = env[AUTHORIZATION_HEADER]
        return nil if header.nil?

        scheme, token = header.to_s.split(" ", 2)
        return nil if scheme.nil? || token.nil?
        return nil unless scheme.casecmp?(SCHEME)

        token = token.strip
        token.empty? ? nil : token
      end

      # Compare the presented token with the secret in constant time.
      def secure_compare?(presented, expected)
        return false unless presented.bytesize == expected.bytesize

        Rack::Utils.secure_compare(presented, expected)
      end

      def unauthorized
        Problem.response(
          status: 401,
          title: "Unauthorized",
          detail: "A valid Bearer token is required to access this endpoint.",
          headers: { "www-authenticate" => CHALLENGE }
        )
      end
    end
  end
end
