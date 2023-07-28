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
                    :automount_service_account_token, :backoff_limit, :active_deadline_seconds,
                    :dns_policy, :restart_policy,
                    :scheduler_name, :service_account, :service_account_name

      alias automountServiceAccountToken automount_service_account_token
      alias backoffLimit backoff_limit
      alias activeDeadlineSeconds active_deadline_seconds
      alias concurrencyPolicy concurrency_policy
      alias dnsPolicy dns_policy
      alias restartPolicy restart_policy
      alias schedulerName scheduler_name
      alias serviceAccount service_account
      alias serviceAccountName service_account_name
      alias startingDeadlineSeconds starting_deadline_seconds
      alias successfulJobsHistoryLimit successful_jobs_history_limit
      alias failedJobsHistoryLimit failed_jobs_history_limit

      def initialize(name, schedule = "* * * * *")
        super(name)
        @schedule = schedule
        @api_version = "batch/v1"
        @restart_policy = "OnFailure"
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
            schedule:,
            suspend:,
            concurrencyPolicy:,
            startingDeadlineSeconds:,
            successfulJobsHistoryLimit:,
            failedJobsHistoryLimit:,
            jobTemplate: {
              spec: {
                activeDeadlineSeconds:,
                backoffLimit:,
                template: {
                  spec: {
                    automountServiceAccountToken:,
                    terminationGracePeriodSeconds:,
                    dnsPolicy:,
                    restartPolicy:,
                    schedulerName:,
                    serviceAccount:,
                    serviceAccountName:,
                    containers: containers.map(&:render),
                    init_containers: init_containers.any? ? init_containers.map(&:render) : nil
                  }.merge(formatted_volumes)
                    .merge(formatted_security_context)
                    .compact
                }.compact
              }.compact
            }.merge(formatted_tolerations)
              .compact
          }.compact
        }
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
