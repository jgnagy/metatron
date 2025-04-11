# frozen_string_literal: true

RSpec.describe Metatron::Templates::VolumeSnapshot do
  describe "for simple volume snapshots" do
    let(:volume_snapshot) do
      described_class.new("hello", source: { persistentVolumeClaimName: "hello" })
    end

    let(:rendered_volume_snapshot) do
      {
        apiVersion: "snapshot.storage.k8s.io/v1",
        kind: "VolumeSnapshot",
        metadata: { labels: { "metatron.therubyist.org/name": "hello" }, name: "hello" },
        spec: {
          source: {
            persistentVolumeClaimName: "hello"
          }
        }
      }
    end

    it "produces a hash" do
      expect(volume_snapshot.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(volume_snapshot.render).to eq(rendered_volume_snapshot)
    end
  end

  describe "for volume snapshots from a persistent volume claim" do
    let(:volume_snapshot) do
      described_class.new(
        "hello",
        source: Metatron::Templates::PersistentVolumeClaim.new(
          "hello",
          storage_class: "test",
          storage: "1Gi"
        ),
        volume_snapshot_class_name: "testClass"
      )
    end

    let(:rendered_volume_snapshot) do
      {
        apiVersion: "snapshot.storage.k8s.io/v1",
        kind: "VolumeSnapshot",
        metadata: { labels: { "metatron.therubyist.org/name": "hello" }, name: "hello" },
        spec: {
          source: {
            persistentVolumeClaimName: "hello"
          },
          volumeSnapshotClassName: "testClass"
        }
      }
    end

    it "produces a hash" do
      expect(volume_snapshot.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(volume_snapshot.render).to eq(rendered_volume_snapshot)
    end
  end
end
