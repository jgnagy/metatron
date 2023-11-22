# frozen_string_literal: true

module Metatron
  module Templates
    # Template for basic RoleBinding k8s resource
    class RoleBinding < Template
      include Concerns::Annotated
      include Concerns::Namespaced

      attr_accessor :role_ref, :subjects, :role

      alias roleRef role_ref

      def initialize(name, role)
        super(name)
        @api_version = "rbac.authorization.k8s.io/v1"
        @role = role
        @role_ref = {
          kind: "Role",
          name: role.respond_to?(:name) ? role.name : role,
          apiGroup: "rbac.authorization.k8s.io"
        }
        @subjects = []
      end

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: base_labels.merge(additional_labels)
          }.merge(formatted_annotations).merge(formatted_namespace).compact,
          roleRef:,
          subjects:
        }.compact
      end
    end
  end
end
