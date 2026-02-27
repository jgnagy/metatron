# frozen_string_literal: true

RSpec.describe Metatron::Templates::TCPRoute do
  describe "for simple TCP routes" do
    let(:route) { described_class.new("test") }

    let(:rendered_route) do
      {
        apiVersion: "gateway.networking.k8s.io/v1alpha2",
        kind: "TCPRoute",
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

  describe "for complex TCP routes" do
    let(:route) do
      r = described_class.new("test")
      r.add_parent_ref(name: "my-gateway", section_name: "tcp-listener")
      r.add_rule(backend_refs: [{ name: "tcp-backend", port: 9000 }])
      r
    end

    let(:rendered_route) do
      {
        apiVersion: "gateway.networking.k8s.io/v1alpha2",
        kind: "TCPRoute",
        metadata: {
          labels: { "metatron.therubyist.org/name": "test" },
          name: "test"
        },
        spec: {
          parentRefs: [{ name: "my-gateway", kind: "Gateway", sectionName: "tcp-listener" }],
          rules: [
            { backendRefs: [{ name: "tcp-backend", port: 9000 }] }
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
