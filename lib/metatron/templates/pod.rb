# frozen_string_literal: true

module Metatron
  module Templates
    # Template for basic Pod k8s resource
    class Pod < Template
      include Concerns::Annotated
      include Concerns::PodProducer
      include Concerns::Namespaced

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            labels: base_labels.merge(additional_labels),
            name:
          }.merge(formatted_annotations).merge(formatted_namespace)
        }.merge(pod_spec)
      end
    end
  end
end
