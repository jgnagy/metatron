# frozen_string_literal: true

module Metatron
  module Controllers
    # Healthcheck service
    class Ping < Sinatra::Application
      configure do
        set :logging, true
        set :logger, Metatron::LOGGER
      end

      before do
        content_type "application/json"

        halt 403 unless request.get? || request.options?

        if request.get?
          headers "X-Frame-Options" => "SAMEORIGIN"
          headers "X-XSS-Protection" => "1; mode=block"
        end
      end

      after do
        headers "Access-Control-Allow-Methods" => %w[GET] if request.options?
      end

      get "/" do
        '{ "status": "up" }'
      end

      options "/" do
        halt 200
      end
    end
  end
end
