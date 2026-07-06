# frozen_string_literal: true

module Metatron
  module Templates
    # Template for HorizontalPodAutoscaler v2 k8s resource
    class HorizontalPodAutoscaler < Template
      include Concerns::Annotated
      include Concerns::Namespaced

      attr_accessor :min_replicas, :max_replicas, :scale_target_ref, :metrics, :behavior

      alias minReplicas min_replicas
      alias maxReplicas max_replicas
      alias scaleTargetRef scale_target_ref

      def initialize(name)
        super
        @api_version = "autoscaling/v2"
        @min_replicas = nil
        @max_replicas = 1
        @scale_target_ref = { apiVersion: "apps/v1", kind: "Deployment", name: name }
      end

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: base_labels.merge(additional_labels)
          }.merge(formatted_annotations).merge(formatted_namespace),
          spec: {
            scaleTargetRef:,
            minReplicas:,
            maxReplicas:,
            metrics:,
            behavior:
          }.compact
        }
      end
    end
  end
end
