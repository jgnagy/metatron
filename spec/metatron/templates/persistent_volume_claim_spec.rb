# frozen_string_literal: true

RSpec.describe Metatron::Templates::PersistentVolumeClaim do
  let(:pvc) do
    described_class.new("test", storage_class: "test", storage: "1Gi").tap do |pvc|
      pvc.data_source = { name: "existing-src-pvc-name", kind: "PersistentVolumeClaim" }
    end
  end

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
        dataSource: {
          name: "existing-src-pvc-name",
          kind: "PersistentVolumeClaim"
        },
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
