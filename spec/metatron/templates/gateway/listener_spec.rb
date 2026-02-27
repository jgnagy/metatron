# frozen_string_literal: true

RSpec.describe Metatron::Templates::Gateway::Listener do
  describe "a minimal listener" do
    let(:listener) { described_class.new("http", port: 80, protocol: "HTTP") }

    it "renders the required fields" do
      expect(listener.render).to eq({ name: "http", port: 80, protocol: "HTTP" })
    end
  end

  describe "a listener with all optional fields" do
    let(:listener) do
      described_class.new(
        "https-foo-bar",
        port: 443,
        protocol: "HTTPS",
        hostname: "foo.bar",
        tls: { mode: "Terminate", certificateRefs: [{ name: "foo-bar-tls" }] },
        allowed_routes: { kinds: [{ kind: "HTTPRoute" }], namespaces: { from: "Same" } }
      )
    end

    it "renders all fields" do
      expect(listener.render).to eq(
        {
          name: "https-foo-bar",
          port: 443,
          protocol: "HTTPS",
          hostname: "foo.bar",
          tls: { mode: "Terminate", certificateRefs: [{ name: "foo-bar-tls" }] },
          allowedRoutes: { kinds: [{ kind: "HTTPRoute" }], namespaces: { from: "Same" } }
        }
      )
    end
  end
end
