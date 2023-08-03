# frozen_string_literal: true

module Metatron
  module Templates
    # The ServiceAccount Kubernetes resource
    class ServiceAccount < Template
      include Concerns::Annotated
      include Concerns::Namespaced

      attr_accessor :automount_service_account_token

      alias automountServiceAccountToken automount_service_account_token

      def render
        {
          apiVersion:,
          kind:,
          automountServiceAccountToken:,
          metadata: {
            name:,
            labels: { "#{label_namespace}/name": name }.merge(additional_labels)
          }.merge(formatted_annotations).merge(formatted_namespace).compact
        }.compact
      end
    end
  end
end
