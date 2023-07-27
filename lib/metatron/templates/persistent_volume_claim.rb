# frozen_string_literal: true

module Metatron
  module Templates
    # The PersistentVolumeClaim Kubernetes resource
    class PersistentVolumeClaim < Template
      include Concerns::Annotated
      include Concerns::Namespaced

      attr_accessor :additional_labels, :storage_class, :access_modes, :storage

      def initialize(
        name,
        storage_class:,
        storage:,
        access_modes: ["ReadWriteOnce"]
      )
        super(name)
        @storage_class = storage_class
        @access_modes = access_modes
        @storage = storage
        @additional_labels = {}
      end

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: { "#{label_namespace}/name": name }.merge(additional_labels)
          }.merge(formatted_annotations).merge(formatted_namespace),
          spec: {
            accessModes: access_modes,
            storageClassName: storage_class,
            resources: {
              requests: {
                storage:
              }
            }
          }
        }
      end
    end
  end
end
