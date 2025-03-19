# frozen_string_literal: true

module Metatron
  module Templates
    module Concerns
      # A mixin to assist with templating Kubernetes resources that create Pods
      module PodProducer
        def self.included(base) # rubocop:disable Metrics/MethodLength
          # base.extend ClassMethods
          base.class_eval do
            attr_accessor :active_deadline_seconds, :additional_pod_labels,
                          :additional_pod_match_labels, :affinity, :automount_service_account_token,
                          :containers, :dns_policy, :enable_service_links, :hostname, :host_ipc,
                          :host_network, :host_pid, :image_pull_secrets, :init_containers,
                          :node_selector, :node_name, :persistent_volume_claims, :pod_annotations,
                          :priority_class_name, :restart_policy, :scheduler_name, :security_context,
                          :service_account, :service_account_name, :share_process_namespace,
                          :subdomain, :termination_grace_period_seconds, :tolerations, :volumes

            initializer :pod_producer_initialize

            alias_method :activeDeadlineSeconds, :active_deadline_seconds
            alias_method :automountServiceAccountToken, :automount_service_account_token
            alias_method :dnsPolicy, :dns_policy
            alias_method :enableServiceLinks, :enable_service_links
            alias_method :hostIPC, :host_ipc
            alias_method :hostNetwork, :host_network
            alias_method :hostPID, :host_pid
            alias_method :priorityClassName, :priority_class_name
            alias_method :nodeSelector, :node_selector
            alias_method :nodeName, :node_name
            alias_method :restartPolicy, :restart_policy
            alias_method :schedulerName, :scheduler_name
            alias_method :securityContext, :security_context
            alias_method :serviceAccount, :service_account
            alias_method :serviceAccountName, :service_account_name
            alias_method :shareProcessNamespace, :share_process_namespace
            alias_method :terminationGracePeriodSeconds, :termination_grace_period_seconds
          end
        end

        def pod_producer_initialize
          @additional_pod_labels = {}
          @additional_pod_match_labels = {}
          @affinity = {}
          @containers = []
          @enable_service_links = nil
          @image_pull_secrets = []
          @init_containers = []
          @node_selector = {}
          @persistent_volume_claims = []
          @pod_annotations = {}
          @priority_class_name = nil
          @restart_policy = nil
          @security_context = {}
          @termination_grace_period_seconds = nil
          @tolerations = []
          @volumes = []
        end

        def formatted_affinity = affinity && !affinity.empty? ? { affinity: } : {}
        def formatted_containers = { containers: containers.map(&:render) }

        def formatted_image_pull_secrets
          if image_pull_secrets&.any?
            { imagePullSecrets: image_pull_secrets.map { _1.is_a?(String) ? { name: _1 } : _1 } }
          else
            {}
          end
        end

        def formatted_init_containers
          if init_containers&.any?
            { initContainers: init_containers.map(&:render) }
          else
            {}
          end
        end

        def formatted_node_selector
          node_selector && !node_selector.empty? ? { nodeSelector: } : {}
        end

        def formatted_pod_annotations
          pod_annotations && !pod_annotations.empty? ? { annotations: pod_annotations } : {}
        end

        def formatted_priority_class_name
          return {} unless priority_class_name

          if priority_class_name.is_a?(String)
            { priorityClassName: priority_class_name }
          elsif priority_class_name.is_a?(PriorityClass)
            { priorityClassName: priority_class_name.name }
          else
            raise "priority_class_name must be a String or a PriorityClass"
          end
        end

        def formatted_security_context
          security_context && !security_context.empty? ? { securityContext: } : {}
        end

        def formatted_tolerations = tolerations&.any? ? { tolerations: } : {}
        def formatted_volumes = volumes&.any? ? { volumes: } : {}

        def volume_claim_templates
          if persistent_volume_claims&.any?
            {
              volumeClaimTemplates: persistent_volume_claims.map do |c|
                c.respond_to?(:render) ? c.render : c
              end
            }
          else
            {}
          end
        end

        def pod_metadata
          {
            metadata: {
              labels: base_labels.merge(additional_pod_labels)
            }.merge(formatted_pod_annotations)
          }
        end

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def pod_spec
          {
            spec: {
              activeDeadlineSeconds:,
              automountServiceAccountToken:,
              dnsPolicy:,
              enableServiceLinks:,
              hostIPC:,
              hostNetwork:,
              hostPID:,
              hostname:,
              nodeName:,
              restartPolicy:,
              schedulerName:,
              serviceAccount:,
              serviceAccountName:,
              shareProcessNamespace:,
              subdomain:,
              terminationGracePeriodSeconds:
            }.merge(formatted_volumes)
              .merge(formatted_affinity)
              .merge(formatted_tolerations)
              .merge(formatted_security_context)
              .merge(formatted_containers)
              .merge(formatted_init_containers)
              .merge(formatted_image_pull_secrets)
              .merge(formatted_node_selector)
              .merge(formatted_priority_class_name)
              .compact
          }.compact
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        def pod_template
          {
            template: {}.merge(pod_metadata).merge(pod_spec).compact
          }
        end
      end
    end
  end
end
