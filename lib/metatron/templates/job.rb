# frozen_string_literal: true

module Metatron
  module Templates
    # Template for basic Job k8s resource
    class Job < Template
      include Concerns::Annotated
      include Concerns::PodProducer
      include Concerns::Namespaced

      attr_accessor :backoff_limit, :completions, :parallelism, :restart_policy,
                    :pod_failure_policy, :active_deadline_seconds, :ttl_seconds_after_finished,
                    :suspend

      alias activeDeadlineSeconds active_deadline_seconds
      alias backoffLimit backoff_limit
      alias podFailurePolicy pod_failure_policy
      alias restartPolicy restart_policy
      alias ttlSecondsAfterFinished ttl_seconds_after_finished

      def initialize(name)
        super(name)
        @api_version = "batch/v1"
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            labels: { "#{label_namespace}/name": name }.merge(additional_labels),
            name:
          }.merge(formatted_annotations).merge(formatted_namespace),
          spec: {
            suspend:,
            backoffLimit:,
            activeDeadlineSeconds:,
            completions:,
            parallelism:,
            podFailurePolicy:,
            ttlSecondsAfterFinished:,
            template: {
              spec: {
                terminationGracePeriodSeconds:,
                restartPolicy:,
                containers: containers.map(&:render),
                init_containers: init_containers.any? ? init_containers.map(&:render) : nil
              }.merge(formatted_volumes)
                .merge(formatted_security_context)
                .merge(formatted_tolerations)
                .compact
            }.compact
          }.compact
        }
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
