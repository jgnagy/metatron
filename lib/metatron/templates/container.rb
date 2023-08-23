# frozen_string_literal: true

module Metatron
  module Templates
    # Template for containers used by k8s resources (not an actual resource)
    class Container
      attr_accessor :name, :image, :command, :args, :env, :envfrom, :resources, :volume_mounts,
                    :image_pull_policy, :lifecycle, :probes, :security_context, :ports,
                    :stdin, :tty, :termination_message_path, :termination_message_policy

      alias imagePullPolicy image_pull_policy
      alias volumeMounts volume_mounts
      alias securityContext security_context
      alias environment env
      alias envFrom envfrom
      alias terminationMessagePath termination_message_path
      alias terminationMessagePolicy termination_message_policy

      def initialize(name, image = "gcr.io/google_containers/pause")
        @name = name
        @image = image
        @command = nil
        @args = []
        @env = []
        @resources = {}
        @volume_mounts = []
        @image_pull_policy = "IfNotPresent"
        @lifecycle = {}
        @probes = {}
        @stdin = true
        @tty = true
        @termination_message_path = nil
        @termination_message_policy = nil
      end

      def render # rubocop:disable Metrics/AbcSize
        {
          name:,
          command:,
          image:,
          imagePullPolicy:,
          stdin:,
          tty:,
          terminationMessagePath:,
          terminationMessagePolicy:,
        }.merge(probes)
          .merge(formatted_resources)
          .merge(formatted_environment)
          .merge(formatted_envfrom)
          .merge(formatted_ports)
          .merge(formatted_volume_mounts)
          .merge(formatted_security_context)
          .merge(formatted_args)
          .merge(formatted_lifecycle)
          .compact
      end

      def formatted_args
        return {} unless args && !args.empty?

        { args: }
      end

      def formatted_lifecycle
        return {} unless lifecycle && !lifecycle.empty?

        { lifecycle: }
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
