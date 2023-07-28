# frozen_string_literal: true

module Metatron
  module Templates
    module Concerns
      # A mixin to assist with templating Kubernetes resources that create Pods
      module PodProducer
        def self.included(base)
          # base.extend ClassMethods
          base.class_eval do
            attr_accessor :additional_labels, :additional_pod_labels,
                          :security_context, :volumes, :containers, :init_containers,
                          :affinity, :termination_grace_period_seconds,
                          :tolerations, :pod_annotations

            initializer :pod_producer_initialize

            alias_method :securityContext, :security_context
            alias_method :terminationGracePeriodSeconds, :termination_grace_period_seconds
          end
        end

        def pod_producer_initialize
          @affinity = {}
          @volumes = []
          @security_context = {}
          @containers = []
          @init_containers = []
          @additional_labels = {}
          @additional_pod_labels = {}
          @pod_annotations = {}
          @termination_grace_period_seconds = nil
          @tolerations = []
        end

        def formatted_affinity = affinity && !affinity.empty? ? { affinity: } : {}

        def formatted_pod_annotations
          pod_annotations && !pod_annotations.empty? ? { annotations: pod_annotations } : {}
        end

        def formatted_security_context
          security_context && !security_context.empty? ? { securityContext: } : {}
        end

        def formatted_tolerations = tolerations&.any? ? { tolerations: } : {}
        def formatted_volumes = volumes&.any? ? { volumes: } : {}
      end
    end
  end
end
