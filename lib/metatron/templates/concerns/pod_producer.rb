# frozen_string_literal: true

module Metatron
  module Templates
    module Concerns
      # A mixin to assist with templating Kubernetes resources that create Pods
      module PodProducer
        def self.included(base)
          # base.extend ClassMethods
          base.class_eval do
            attr_accessor :image, :image_pull_policy, :additional_labels, :env, :envfrom,
                          :resource_limits, :resource_requests, :probes, :ports, :security_context,
                          :volume_mounts, :volumes, :additional_containers,
                          :container_security_context, :affinity, :termination_grace_period_seconds

            initializer :pod_producer_initialize

            alias_method :imagePullPolicy, :image_pull_policy
            alias_method :volumeMounts, :volume_mounts
            alias_method :securityContext, :security_context
            alias_method :environment, :env
            alias_method :terminationGracePeriodSeconds, :termination_grace_period_seconds
          end
        end

        def pod_producer_initialize
          @image = "gcr.io/google_containers/pause"
          @image_pull_policy = "IfNotPresent"
          @resource_limits = { memory: "512Mi", cpu: "500m" }
          @resource_requests = { memory: "64Mi", cpu: "10m" }
          @affinity = {}
          @env = {}
          @envfrom = []
          @probes = {}
          @ports = []
          @volume_mounts = []
          @volumes = []
          @security_context = {}
          @container_security_context = {}
          @additional_containers = []
          @additional_labels = {}
          @termination_grace_period_seconds = 60
        end

        def formatted_affinity
          affinity && !affinity.empty? ? { affinity: } : {}
        end

        def formatted_environment
          env && !env.empty? ? { env: env.map { |k, v| { name: k, value: v } } } : {}
        end

        def formatted_envfrom
          if envfrom && !envfrom.empty?
            { envFrom: envfrom.map { |secret| { secretRef: { name: secret } } } }
          else
            {}
          end
        end

        def formatted_ports
          ports&.any? ? { ports: } : {}
        end

        def formatted_security_context
          security_context && !security_context.empty? ? { securityContext: } : {}
        end

        def formatted_container_security_context
          if container_security_context && !container_security_context.empty?
            { securityContext: container_security_context }
          else
            {}
          end
        end

        def formatted_volume_mounts
          volume_mounts&.any? ? { volumeMounts: } : {}
        end

        def formatted_volumes
          volumes&.any? ? { volumes: } : {}
        end
      end
    end
  end
end
