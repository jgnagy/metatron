# frozen_string_literal: true

module Metatron
  module Templates
    # Template for basic CronJob k8s resource
    class CronJob < Template
      include Concerns::Annotated
      include Concerns::PodProducer
      include Concerns::Namespaced

      attr_accessor :schedule, :suspend, :concurrency_policy, :starting_deadline_seconds,
                    :successful_jobs_history_limit, :failed_jobs_history_limit,
                    :job_active_deadline_seconds, :ttl_seconds_after_finished,
                    :backoff_limit, :time_zone

      alias backoffLimit backoff_limit
      alias concurrencyPolicy concurrency_policy
      alias startingDeadlineSeconds starting_deadline_seconds
      alias successfulJobsHistoryLimit successful_jobs_history_limit
      alias failedJobsHistoryLimit failed_jobs_history_limit
      alias timeZone time_zone
      alias ttlSecondsAfterFinished ttl_seconds_after_finished

      def initialize(name, schedule = "* * * * *")
        super(name)
        @schedule = schedule
        @api_version = "batch/v1"
      end

      # rubocop:disable Metrics/AbcSize
      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            labels: base_labels.merge(additional_labels),
            name:
          }.merge(formatted_annotations).merge(formatted_namespace),
          spec: {
            schedule:,
            suspend:,
            concurrencyPolicy:,
            startingDeadlineSeconds:,
            successfulJobsHistoryLimit:,
            failedJobsHistoryLimit:,
            timeZone:,
            jobTemplate: {
              spec: {
                activeDeadlineSeconds: job_active_deadline_seconds,
                backoffLimit:,
                ttlSecondsAfterFinished:
              }.merge(pod_template).compact
            }.merge(formatted_tolerations).compact
          }.compact
        }
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
