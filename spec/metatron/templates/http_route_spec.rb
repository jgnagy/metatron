# frozen_string_literal: true

RSpec.describe Metatron::Templates::HTTPRoute do
  describe "for simple HTTP routes" do
    let(:route) { described_class.new("test") }

    let(:rendered_route) do
      {
        apiVersion: "gateway.networking.k8s.io/v1",
        kind: "HTTPRoute",
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

  describe "for complex HTTP routes (keyword form)" do
    let(:route) do
      r = described_class.new("test")
      r.add_parent_ref(name: "my-gateway")
      r.add_hostname("foo.example.com")
      r.add_rule(
        backend_refs: [{ name: "foo-svc", port: 8080 }],
        matches: [{ path: { type: "PathPrefix", value: "/api" } }]
      )
      r
    end

    let(:rendered_route) do
      {
        apiVersion: "gateway.networking.k8s.io/v1",
        kind: "HTTPRoute",
        metadata: {
          labels: { "metatron.therubyist.org/name": "test" },
          name: "test"
        },
        spec: {
          parentRefs: [{ name: "my-gateway", kind: "Gateway" }],
          hostnames: ["foo.example.com"],
          rules: [
            {
              backendRefs: [{ name: "foo-svc", port: 8080 }],
              matches: [{ path: { type: "PathPrefix", value: "/api" } }]
            }
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

  describe "for complex HTTP routes (object form)" do
    let(:route) do
      r = described_class.new("test")
      r.add_parent_ref(name: "my-gateway")
      r.add_hostname("foo.example.com")
      r.add_rule(
        Metatron::Templates::HTTPRoute::Rule.new(
          backend_refs: [{ name: "foo-svc", port: 8080 }],
          matches: [{ path: { type: "PathPrefix", value: "/api" } }]
        )
      )
      r
    end

    it "renders identically to the keyword form" do
      keyword_route = described_class.new("test")
      keyword_route.add_parent_ref(name: "my-gateway")
      keyword_route.add_hostname("foo.example.com")
      keyword_route.add_rule(
        backend_refs: [{ name: "foo-svc", port: 8080 }],
        matches: [{ path: { type: "PathPrefix", value: "/api" } }]
      )
      expect(route.render).to eq(keyword_route.render)
    end
  end
end
