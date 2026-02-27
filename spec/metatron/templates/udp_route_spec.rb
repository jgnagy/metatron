# frozen_string_literal: true

RSpec.describe Metatron::Templates::UDPRoute do
  describe "for simple UDP routes" do
    let(:route) { described_class.new("test") }

    let(:rendered_route) do
      {
        apiVersion: "gateway.networking.k8s.io/v1alpha2",
        kind: "UDPRoute",
        metadata: {
          labels: { "metatron.therubyist.org/name": "test" },
          name: "test"
        },
        spec: {}
      }
    end

    it "produces a hash" do
      expect(route.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(route.render).to eq(rendered_route)
    end
  end

  describe "for complex UDP routes" do
    let(:route) do
      r = described_class.new("test")
      r.add_parent_ref(name: "my-gateway")
      r.add_rule(backend_refs: [{ name: "dns-backend", port: 53 }])
      r
    end

    let(:rendered_route) do
      {
        apiVersion: "gateway.networking.k8s.io/v1alpha2",
        kind: "UDPRoute",
        metadata: {
          labels: { "metatron.therubyist.org/name": "test" },
          name: "test"
        },
        spec: {
          parentRefs: [{ name: "my-gateway", kind: "Gateway" }],
          rules: [
            { backendRefs: [{ name: "dns-backend", port: 53 }] }
          ]
        }
      }
    end

    it "produces a hash" do
      expect(route.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(route.render).to eq(rendered_route)
    end
  end
end
