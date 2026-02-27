# frozen_string_literal: true

RSpec.describe Metatron::Templates::GRPCRoute do
  describe "for simple gRPC routes" do
    let(:route) { described_class.new("test") }

    let(:rendered_route) do
      {
        apiVersion: "gateway.networking.k8s.io/v1",
        kind: "GRPCRoute",
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

  describe "for complex gRPC routes" do
    let(:route) do
      r = described_class.new("test")
      r.add_parent_ref(name: "my-gateway")
      r.add_hostname("api.example.com")
      r.add_rule(
        backend_refs: [{ name: "grpc-svc", port: 50_051 }],
        matches: [{ method: { service: "helloworld.Greeter", method: "SayHello" } }]
      )
      r
    end

    let(:rendered_route) do
      {
        apiVersion: "gateway.networking.k8s.io/v1",
        kind: "GRPCRoute",
        metadata: {
          labels: { "metatron.therubyist.org/name": "test" },
          name: "test"
        },
        spec: {
          parentRefs: [{ name: "my-gateway", kind: "Gateway" }],
          hostnames: ["api.example.com"],
          rules: [
            {
              backendRefs: [{ name: "grpc-svc", port: 50_051 }],
              matches: [{ method: { service: "helloworld.Greeter", method: "SayHello" } }]
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
end
