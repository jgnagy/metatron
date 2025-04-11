# frozen_string_literal: true

module Metatron
  module Templates
    # The VolumeSnapshotContent Kubernetes resource
    class VolumeSnapshotContent < Template
      include Concerns::Annotated
      include Concerns::Namespaced

      attr_accessor :source, :deletion_policy, :driver, :source_volume_mode, :volume_snapshot_ref

      alias deletionPolicy deletion_policy
      alias sourceVolumeMode source_volume_mode
      alias volumeSnapshotRef volume_snapshot_ref

      def initialize(name, driver:, source: {}, deletion_policy: "Delete",
                     volume_snapshot_ref: nil, source_volume_mode: "Filesystem")
        super(name)
        @api_version = "snapshot.storage.k8s.io/v1"
        @driver = driver
        @source = source
        @source_volume_mode = source_volume_mode
        @deletion_policy = deletion_policy
        @volume_snapshot_ref = volume_snapshot_ref
      end

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: base_labels.merge(additional_labels)
          }.merge(formatted_annotations).merge(formatted_namespace).compact,
          spec: {
            driver:,
            deletionPolicy:,
            sourceVolumeMode:
          }.merge(formatted_source).merge(formatted_volume_snapshot_ref).compact
        }.compact
      end

      def formatted_source
        return {} unless source
        raise ArgumentError, "Invalid source type: #{source.class}." unless source.is_a?(Hash)

        { source: }
      end

      def formatted_volume_snapshot_ref
        return {} unless volume_snapshot_ref

        if volume_snapshot_ref.is_a?(Hash)
          { volumeSnapshotRef: }
        elsif volume_snapshot_ref.is_a?(VolumeSnapshot)
          {
            volumeSnapshotRef: {
              name: volume_snapshot_ref.name,
              namespace: volume_snapshot_ref.namespace
            }.compact
          }
        else
          raise ArgumentError,
                "Invalid volume_snapshot_ref type: #{volume_snapshot_ref.class}."
        end
      end
    end
  end
end
