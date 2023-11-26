# frozen_string_literal: true

RSpec.describe Metatron::Templates::NetworkPolicy do
  let(:network_policy) do
    policy = described_class.new("test")
    policy.pod_selector = { "kind" => "testpod" }
    policy.ingress = [
      {
        "ports" => [{ "port" => 3306 }]
      }
    ]
    policy.egress = [
      {
        "ports" => [{ "port" => 5000 }]
      }
    ]
    policy
  end

  let(:rendered_network_policy) do
    {
      apiVersion: "v1",
      kind: "NetworkPolicy",
      metadata: {
        name: "test",
        labels: { "metatron.therubyist.org/name": "test" }
      },
      spec: {
        podSelector: { "kind" => "testpod" },
        ingress: [
          {
            "ports" => [{ "port" => 3306 }]
          }
        ],
        egress: [
          {
            "ports" => [{ "port" => 5000 }]
          }
        ]
      }
    }
  end

  it "produces a hash" do
    expect(network_policy.render).to be_a(Hash)
  end

  it "renders properly" do
    expect(network_policy.render).to eq(rendered_network_policy)
  end
end
