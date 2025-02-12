# frozen_string_literal: true

module Metatron
  module Templates
    # The PersistentVolumeClaim Kubernetes resource
    class PersistentVolumeClaim < Template
      include Concerns::Annotated
      include Concerns::Namespaced

      attr_accessor :additional_labels, :data_source, :data_source_ref, :storage_class,
                    :access_modes, :storage

      alias storageClassName storage_class
      alias accessModes access_modes
      alias dataSource data_source
      alias dataSourceRef data_source_ref

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
        @data_source = {}
        @additional_labels = {}
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
            accessModes:,
            storageClassName:,
            resources: {
              requests: {
                storage:
              }
            }
          }.merge(formatted_data_source).merge(formatted_data_source_ref)
        }
      end

      def formatted_data_source
        return {} unless data_source && !data_source.empty?
        raise "dataSource must be a Hash" unless data_source.is_a?(Hash)

        valid_keys = %i[apiGroup kind name]
        unless data_source.keys.all? { valid_keys.include?(_1.to_sym) }
          raise "dataSource may contain only the keys: #{valid_keys.join(", ")}"
        end

        { dataSource: data_source.transform_keys(&:to_sym) }
      end

      def formatted_data_source_ref
        return {} unless data_source_ref && !data_source_ref.empty?
        raise "dataSourceRef must be a Hash" unless data_source_ref.is_a?(Hash)

        valid_keys = %i[apiGroup kind name namespace]
        unless data_source_ref.keys.all? { valid_keys.include?(_1.to_sym) }
          raise "dataSourceRef may contain only the keys: #{valid_keys.join(", ")}"
        end

        { dataSourceRef: data_source_ref.transform_keys(&:to_sym) }
      end
    end
  end
end
