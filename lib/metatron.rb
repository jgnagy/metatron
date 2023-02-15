# frozen_string_literal: true

# Standard Library requirements
require "base64"
require "resolv"
require "securerandom"
require "time"
require "logger"

# External requirements
require "sinatra/base"
require "sinatra/custom_logger"

# The top-level module for Bullion
module Metatron
  class Error < StandardError; end
  class ConfigError < Error; end

  LOGGER = Logger.new($stdout)

  # Set up log level
  LOGGER.level = ENV.fetch("LOG_LEVEL", :warn)
end

# Internal requirements
require "metatron/version"
require "metatron/template"
require "metatron/templates/concerns/annotated"
require "metatron/templates/concerns/pod_producer"
require "metatron/templates/pod"
require "metatron/templates/deployment"
require "metatron/templates/ingress"
require "metatron/templates/replica_set"
require "metatron/templates/secret"
require "metatron/templates/service"
require "metatron/templates/stateful_set"
require "metatron/controller"
require "metatron/sync_controller"
require "metatron/controllers/ping"
