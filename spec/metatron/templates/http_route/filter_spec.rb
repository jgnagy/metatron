# frozen_string_literal: true

RSpec.describe Metatron::Templates::HTTPRoute::Filter do
  describe "URLRewrite filter" do
    let(:filter) do
      described_class.new(
        type: "URLRewrite",
        hostname: "example.net",
        path: { type: "ReplacePrefixMatch", replacePrefixMatch: "/bar" }
      )
    end

    it "nests config under the derived camelCase key" do
      expect(filter.render).to eq(
        {
          type: "URLRewrite",
          urlRewrite: {
            hostname: "example.net",
            path: { type: "ReplacePrefixMatch", replacePrefixMatch: "/bar" }
          }
        }
      )
    end
  end

  describe "RequestHeaderModifier filter" do
    let(:filter) do
      described_class.new(
        type: "RequestHeaderModifier",
        add: [{ name: "X-Custom-Header", value: "custom-value" }],
        remove: ["X-Remove-Header"]
      )
    end

    it "nests config under the derived camelCase key" do
      expect(filter.render).to eq(
        {
          type: "RequestHeaderModifier",
          requestHeaderModifier: {
            add: [{ name: "X-Custom-Header", value: "custom-value" }],
            remove: ["X-Remove-Header"]
          }
        }
      )
    end
  end

  describe "RequestRedirect filter" do
    let(:filter) do
      described_class.new(type: "RequestRedirect", hostname: "new.example.com", statusCode: 301)
    end

    it "nests config under the derived camelCase key" do
      expect(filter.render).to eq(
        {
          type: "RequestRedirect",
          requestRedirect: { hostname: "new.example.com", statusCode: 301 }
        }
      )
    end
  end

  describe "a filter with no config" do
    let(:filter) { described_class.new(type: "ExtensionRef") }

    it "renders only the type" do
      expect(filter.render).to eq({ type: "ExtensionRef" })
    end
  end
end
