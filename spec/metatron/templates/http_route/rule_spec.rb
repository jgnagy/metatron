# frozen_string_literal: true

RSpec.describe Metatron::Templates::HTTPRoute::Rule do
  describe "a minimal rule" do
    let(:rule) { described_class.new(backend_refs: [{ name: "foo-svc", port: 8080 }]) }

    it "renders only backendRefs" do
      expect(rule.render).to eq({ backendRefs: [{ name: "foo-svc", port: 8080 }] })
    end
  end

  describe "a rule with matches" do
    let(:rule) do
      described_class.new(
        backend_refs: [{ name: "foo-svc", port: 8080 }],
        matches: [{ path: { type: "PathPrefix", value: "/api" } }]
      )
    end

    it "renders backendRefs and matches" do
      expect(rule.render).to eq(
        {
          backendRefs: [{ name: "foo-svc", port: 8080 }],
          matches: [{ path: { type: "PathPrefix", value: "/api" } }]
        }
      )
    end
  end

  describe "a rule with filters" do
    let(:rule) do
      r = described_class.new(backend_refs: [{ name: "foo-svc", port: 8080 }])
      r.add_filter(
        type: "URLRewrite",
        hostname: "example.net",
        path: { type: "ReplacePrefixMatch", replacePrefixMatch: "/bar" }
      )
      r
    end

    let(:expected_rewrite) do
      {
        hostname: "example.net",
        path: { type: "ReplacePrefixMatch", replacePrefixMatch: "/bar" }
      }
    end

    it "renders filters via Filter#render" do
      expect(rule.render).to eq(
        {
          backendRefs: [{ name: "foo-svc", port: 8080 }],
          filters: [
            { type: "URLRewrite", urlRewrite: expected_rewrite }
          ]
        }
      )
    end
  end
end
