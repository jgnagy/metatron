# frozen_string_literal: true

module Metatron
  module Templates
    # The VolumeSnapshot Kubernetes resource
    class VolumeSnapshot < Template
      include Concerns::Annotated
      include Concerns::Namespaced

      attr_accessor :source, :volume_snapshot_class_name

      alias volumeSnapshotClassName volume_snapshot_class_name

      def initialize(name, source: {}, volume_snapshot_class_name: nil)
        super(name)
        @source = source
        @volume_snapshot_class_name = volume_snapshot_class_name
        @api_version = "snapshot.storage.k8s.io/v1"
      end

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: base_labels.merge(additional_labels)
          }.merge(formatted_annotations).merge(formatted_namespace).compact,
          spec: {}.merge(formatted_source).merge(formatted_volume_snapshot_class_name).compact
        }.compact
      end

      def formatted_source
        case source
        when Hash
          { source: }
        when Metatron::Templates::VolumeSnapshotContent
          { source: { volumeSnapshotContentName: source.name } }
        when Metatron::Templates::PersistentVolumeClaim
          { source: { persistentVolumeClaimName: source.name } }
        when nil
          {}
        else
          raise ArgumentError,
                "Invalid source type: #{source.class}. " \
                "Expected Hash, VolumeSnapshotContent, or PersistentVolumeClaim."
        end
      end

      def formatted_volume_snapshot_class_name
        return {} unless volume_snapshot_class_name

        if volume_snapshot_class_name.is_a?(String)
          { volumeSnapshotClassName: }
        elsif volume_snapshot_class_name.respond_to?(:name)
          { volumeSnapshotClassName: volume_snapshot_class_name.name }
        else
          raise ArgumentError,
                "Invalid volume_snapshot_class_name type: #{volume_snapshot_class_name.class}."
        end
      end
    end
  end
end
