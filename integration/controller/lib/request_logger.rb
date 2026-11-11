# frozen_string_literal: true

module IntegrationController
  # Logs the final status of each request so integration specs can prove that
  # paths like ETag short-circuiting (304) and auth rejection (401) actually
  # happened in the cluster.
  class RequestLogger
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      Metatron.logger.info("#{env["REQUEST_METHOD"]} #{env["PATH_INFO"]} -> #{status}")
      [status, headers, body]
    end
  end
end
