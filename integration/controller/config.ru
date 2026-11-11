# frozen_string_literal: true

require "rack"
require "metatron"
require_relative "lib/request_logger"
require_relative "lib/widget_controller"

# The secured stack mirrors a realistic Metatron deployment: body limits and
# bearer-token auth in front of the CompositeController. `/ping` stays outside
# the auth stack so Kubernetes probes can reach it without a credential.
secured = Rack::Builder.new do
  use IntegrationController::RequestLogger
  use Metatron::Middleware::BodyLimit
  use Metatron::Middleware::Auth
  run IntegrationController::WidgetController
end

run Rack::URLMap.new(
  "/ping" => Metatron::Controllers::Ping,
  "/widgets" => secured
)
