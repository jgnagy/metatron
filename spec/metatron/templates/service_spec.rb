# frozen_string_literal: true

RSpec.describe Metatron::Templates::Service do
  let(:service) do
    service = described_class.new("test", 3306)
    service.selector = { "foo.bar/name": "test" }
    service
  end

  let(:rendered_service_with_cluster_ip_none) do
    {
      apiVersion: "v1",
      kind: "Service",
      metadata: {
        labels: { "metatron.therubyist.org/name": "test" },
        name: "test"
      },
      spec: {
        selector: { "foo.bar/name": "test" },
        type: "ClusterIP",
        clusterIP: "None",
        ports: [
          { name: "test", port: 3306, protocol: "TCP", targetPort: 3306 }
        ]
      }
    }
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
        selector: { "foo.bar/name": "test" },
        type: "ClusterIP",
        ports: [
          { name: "test", port: 3306, protocol: "TCP", targetPort: 3306 }
        ]
      }
    }
  end

  let(:rendered_service_with_publish_not_ready_addresses) do
    {
      apiVersion: "v1",
      kind: "Service",
      metadata: {
        labels: { "metatron.therubyist.org/name": "test" },
        name: "test"
      },
      spec: {
        publishNotReadyAddresses: true,
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

  it "renders properly with clusterIP: None" do
    service.cluster_ip = "None"
    expect(service.render).to eq(rendered_service_with_cluster_ip_none)
  end

  it "renders properly with publishNotReadyAddresses: true" do
    service.publish_not_ready_addresses = true
    expect(service.render).to eq(rendered_service_with_publish_not_ready_addresses)
  end
end
