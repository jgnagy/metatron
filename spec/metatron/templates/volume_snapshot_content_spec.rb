# frozen_string_literal: true

RSpec.describe Metatron::Templates::VolumeSnapshotContent do
  describe "for simple volume snapshot contents" do
    let(:volume_snapshot_content) do
      described_class.new(
        "new-snapshot-content-test",
        source: { snapshotHandle: "7bdd0de3-aaeb-11e8-9aae-0242ac110002" },
        driver: "hostpath.csi.k8s.io",
        volume_snapshot_ref: {
          name: "new-snapshot-test",
          namespace: "foo"
        }
      )
    end

    let(:rendered_volume_snapshot_content) do
      {
        apiVersion: "snapshot.storage.k8s.io/v1",
        kind: "VolumeSnapshotContent",
        metadata: {
          name: "new-snapshot-content-test",
          labels: { "metatron.therubyist.org/name": "new-snapshot-content-test" }
        },
        spec: {
          deletionPolicy: "Delete",
          driver: "hostpath.csi.k8s.io",
          source: {
            snapshotHandle: "7bdd0de3-aaeb-11e8-9aae-0242ac110002"
          },
          sourceVolumeMode: "Filesystem",
          volumeSnapshotRef: {
            name: "new-snapshot-test",
            namespace: "foo"
          }
        }
      }
    end

    it "produces a hash" do
      expect(volume_snapshot_content.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(volume_snapshot_content.render).to eq(rendered_volume_snapshot_content)
    end
  end

  describe "for volume snapshot contents provided a volume snapshot" do
    let(:volume_snapshot) do
      snapshot = Metatron::Templates::VolumeSnapshot.new(
        "new-snapshot-test",
        source: { persistentVolumeClaimName: "hello" },
        volume_snapshot_class_name: "testClass"
      )
      snapshot.namespace = "foo"
      snapshot
    end

    let(:volume_snapshot_content) do
      described_class.new(
        "new-snapshot-content-test",
        source: { snapshotHandle: "7bdd0de3-aaeb-11e8-9aae-0242ac110003" },
        driver: "hostpath.csi.k8s.io",
        volume_snapshot_ref: volume_snapshot
      )
    end

    let(:rendered_volume_snapshot_content) do
      {
        apiVersion: "snapshot.storage.k8s.io/v1",
        kind: "VolumeSnapshotContent",
        metadata: {
          name: "new-snapshot-content-test",
          labels: { "metatron.therubyist.org/name": "new-snapshot-content-test" }
        },
        spec: {
          deletionPolicy: "Delete",
          driver: "hostpath.csi.k8s.io",
          source: {
            snapshotHandle: "7bdd0de3-aaeb-11e8-9aae-0242ac110003"
          },
          sourceVolumeMode: "Filesystem",
          volumeSnapshotRef: {
            name: "new-snapshot-test",
            namespace: "foo"
          }
        }
      }
    end

    it "produces a hash" do
      expect(volume_snapshot_content.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(volume_snapshot_content.render).to eq(rendered_volume_snapshot_content)
    end
  end
end
