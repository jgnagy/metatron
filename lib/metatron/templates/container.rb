# frozen_string_literal: true

module Metatron
  module Templates
    # Template for containers used by k8s resources (not an actual resource)
    class Container
      attr_accessor :name, :image, :command, :args, :env, :envfrom, :resources, :volume_mounts,
                    :image_pull_policy, :life_cycle, :probes, :security_context, :ports,
                    :stdin, :tty

      alias imagePullPolicy image_pull_policy
      alias volumeMounts volume_mounts
      alias securityContext security_context
      alias environment env
      alias envFrom envfrom

      def initialize(name, image = "gcr.io/google_containers/pause")
        @name = name
        @image = image
        @command = nil
        @args = []
        @env = []
        @resources = {}
        @volume_mounts = []
        @image_pull_policy = "IfNotPresent"
        @life_cycle = {}
        @probes = {}
        @stdin = true
        @tty = true
      end

      def render
        {
          name:,
          image:,
          imagePullPolicy:,
          stdin:,
          tty:
        }.merge(probes)
          .merge(formatted_resources)
          .merge(formatted_environment)
          .merge(formatted_envfrom)
          .merge(formatted_ports)
          .merge(formatted_volume_mounts)
          .merge(formatted_security_context)
          .compact
      end

      def formatted_environment # rubocop:disable Metrics/PerceivedComplexity
        return {} unless env && !env.empty?

        if env.is_a?(Hash)
          mapped_values = env.map do |key, value|
            v = { name: key }
            if value.is_a?(Hash)
              v.merge!(value)
            else
              v[:value] = value
            end
            v
          end

          { env: mapped_values }
        elsif env.is_a?(Array)
          { env: }
        else
          raise "Environment must be a Hash or Array"
        end
      end

      def formatted_envfrom
        if envfrom && !envfrom.empty?
          { envFrom: envfrom.map { |secret| { secretRef: { name: secret } } } }
        else
          {}
        end
      end

      def formatted_resources = resources&.any? ? { resources: } : {}

      def formatted_ports = ports&.any? ? { ports: } : {}

      def formatted_security_context
        security_context && !security_context.empty? ? { securityContext: } : {}
      end

      def formatted_volume_mounts = volume_mounts&.any? ? { volumeMounts: } : {}
    end
  end
end