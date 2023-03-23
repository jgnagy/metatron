# frozen_string_literal: true

RSpec.describe Metatron::Templates::PersistentVolumeClaim do
  let(:pvc) { described_class.new("test", storage_class: "test", storage: "1Gi") }

  let(:rendered_pvc) do
    {
      apiVersion: "v1",
      kind: "PersistentVolumeClaim",
      metadata: {
        name: "test",
        labels: { "metatron.therubyist.org/name": "test" }
      },
      spec: {
        accessModes: ["ReadWriteOnce"],
        storageClassName: "test",
        resources: {
          requests: {
            storage: "1Gi"
          }
        }
      }
    }
  end

  it "produces a hash" do
    expect(pvc.render).to be_a(Hash)
  end

  it "renders properly" do
    expect(pvc.render).to eq(rendered_pvc)
  end
end
