# frozen_string_literal: true

RSpec.describe Metatron::Templates::GRPCRoute::Filter do
  describe "RequestHeaderModifier filter" do
    let(:filter) do
      described_class.new(
        type: "RequestHeaderModifier",
        add: [{ name: "X-Custom-Header", value: "custom-value" }]
      )
    end

    it "nests config under the derived camelCase key" do
      expect(filter.render).to eq(
        {
          type: "RequestHeaderModifier",
          requestHeaderModifier: { add: [{ name: "X-Custom-Header", value: "custom-value" }] }
        }
      )
    end
  end

  describe "RequestMirror filter" do
    let(:filter) do
      described_class.new(
        type: "RequestMirror",
        backendRef: { name: "mirror-svc", port: 8080 }
      )
    end

    it "nests config under the derived camelCase key" do
      expect(filter.render).to eq(
        {
          type: "RequestMirror",
          requestMirror: { backendRef: { name: "mirror-svc", port: 8080 } }
        }
      )
    end
  end
end
