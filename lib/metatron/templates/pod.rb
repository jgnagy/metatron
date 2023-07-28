# frozen_string_literal: true

module Metatron
  module Templates
    # Template for basic Pod k8s resource
    class Pod < Template
      include Concerns::Annotated
      include Concerns::PodProducer
      include Concerns::Namespaced

      # rubocop:disable Metrics/AbcSize
      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            labels: { "#{label_namespace}/name": name }.merge(additional_labels),
            name:
          }.merge(formatted_annotations).merge(formatted_namespace),
          spec: {
            terminationGracePeriodSeconds:,
            containers: containers.map(&:render),
            init_containers: init_containers.any? ? init_containers.map(&:render) : nil
          }.merge(formatted_volumes)
            .merge(formatted_security_context)
            .merge(formatted_tolerations)
            .compact
        }
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
