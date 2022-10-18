# frozen_string_literal: true

RSpec.describe Metatron::Templates::Service do
  let(:service) do
    service = described_class.new("test", 3306)
    service.selector = { "foo.bar/name": "test" }
    service
  end

  let(:rendered_service) do
    {
      apiVersion: "v1",
      kind: "Service",
      metadata: {
        labels: { "metatron.therubyist.org/name": "test" },
        name: "test"
      },
      spec: {
        publishNotReadyAddresses: false,
        selector: { "foo.bar/name": "test" },
        type: "ClusterIP",
        ports: [
          { name: "test", port: 3306, protocol: "TCP", targetPort: 3306 }
        ]
      }
    }
  end

  it "produces a hash" do
    expect(service.render).to be_a(Hash)
  end

  it "renders properly" do
    expect(service.render).to eq(rendered_service)
  end
end
