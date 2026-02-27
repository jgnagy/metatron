# frozen_string_literal: true

RSpec.describe Metatron::Templates::GRPCRoute::Rule do
  describe "a minimal rule" do
    let(:rule) { described_class.new(backend_refs: [{ name: "grpc-svc", port: 50_051 }]) }

    it "renders only backendRefs" do
      expect(rule.render).to eq({ backendRefs: [{ name: "grpc-svc", port: 50_051 }] })
    end
  end

  describe "a rule with matches and a filter" do
    let(:rule) do
      r = described_class.new(
        backend_refs: [{ name: "grpc-svc", port: 50_051 }],
        matches: [{ method: { service: "helloworld.Greeter", method: "SayHello" } }]
      )
      r.add_filter(type: "RequestHeaderModifier", add: [{ name: "X-Custom", value: "val" }])
      r
    end

    let(:expected_filters) do
      [
        {
          type: "RequestHeaderModifier",
          requestHeaderModifier: { add: [{ name: "X-Custom", value: "val" }] }
        }
      ]
    end

    it "renders all fields" do
      expect(rule.render).to eq(
        {
          backendRefs: [{ name: "grpc-svc", port: 50_051 }],
          matches: [{ method: { service: "helloworld.Greeter", method: "SayHello" } }],
          filters: expected_filters
        }
      )
    end
  end
end
