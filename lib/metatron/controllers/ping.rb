# frozen_string_literal: true

module Metatron
  module Controllers
    # Healthcheck service
    class Ping
      RESPONSE = { status: "up" }.to_json

      def call(env)
        req = Rack::Request.new(env)

        return access_control_allow_methods if req.options?
        return [403, { Rack::CONTENT_TYPE => "application/json" }, []] unless req.get?

        Rack::Response[200, {
          "content-type" => "application/json",
          "x-frame-options" => "SAMEORIGIN",
          "x-xss-protection" => "1; mode=block"
        }, [RESPONSE]].to_a
      end

      private

      def access_control_allow_methods
        Rack::Response[200, { "access-control-allow-methods" => %w[GET] }, []].to_a
      end
    end
  end
end
