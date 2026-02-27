# frozen_string_literal: true

RSpec.describe Metatron::Templates::TLSRoute do
  describe "for simple TLS routes" do
    let(:route) { described_class.new("test") }

    let(:rendered_route) do
      {
        apiVersion: "gateway.networking.k8s.io/v1",
        kind: "TLSRoute",
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

  describe "for complex TLS routes" do
    let(:route) do
      r = described_class.new("test")
      r.add_parent_ref(name: "tls-gateway")
      r.add_hostname("api.example.com")
      r.add_rule(backend_refs: [{ name: "tls-backend", port: 8443 }])
      r
    end

    let(:rendered_route) do
      {
        apiVersion: "gateway.networking.k8s.io/v1",
        kind: "TLSRoute",
        metadata: {
          labels: { "metatron.therubyist.org/name": "test" },
          name: "test"
        },
        spec: {
          parentRefs: [{ name: "tls-gateway", kind: "Gateway" }],
          hostnames: ["api.example.com"],
          rules: [
            { backendRefs: [{ name: "tls-backend", port: 8443 }] }
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
