# frozen_string_literal: true

# Standard Library requirements
require "resolv"
require "securerandom"
require "time"
require "logger"

# external requirements
require "base64"

# The top-level module for Metatron
module Metatron
  class Error < StandardError; end
  class ConfigError < Error; end

  singleton_class.attr_accessor :logger
  self.logger = Logger.new($stdout, level: ENV.fetch("LOG_LEVEL", :warn))
end

# Internal requirements
require "metatron/version"
require "metatron/template"
require "metatron/templates/concerns/annotated"
require "metatron/templates/concerns/namespaced"
require "metatron/templates/concerns/pod_producer"
require "metatron/templates/container"
require "metatron/templates/pod"
require "metatron/templates/job"
require "metatron/templates/config_map"
require "metatron/templates/cluster_role"
require "metatron/templates/cluster_role_binding"
require "metatron/templates/cron_job"
require "metatron/templates/daemon_set"
require "metatron/templates/deployment"
require "metatron/templates/ingress"
require "metatron/templates/limit_range"
require "metatron/templates/namespace"
require "metatron/templates/network_policy"
require "metatron/templates/persistent_volume_claim"
require "metatron/templates/priority_class"
require "metatron/templates/replica_set"
require "metatron/templates/resource_quota"
require "metatron/templates/role"
require "metatron/templates/role_binding"
require "metatron/templates/secret"
require "metatron/templates/service"
require "metatron/templates/service_account"
require "metatron/templates/stateful_set"
require "metatron/templates/volume_snapshot"
require "metatron/templates/volume_snapshot_content"
require "metatron/controller"
require "metatron/composite_controller"
require "metatron/controllers/ping"
require "metatron/railtie" if defined? Rails::Railtie
