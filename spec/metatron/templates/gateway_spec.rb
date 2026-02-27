# frozen_string_literal: true

RSpec.describe Metatron::Templates::Gateway do
  describe "for simple gateways" do
    let(:gateway) { described_class.new("test", gateway_class_name: "envoy-gateway") }

    let(:rendered_gateway) do
      {
        apiVersion: "gateway.networking.k8s.io/v1",
        kind: "Gateway",
        metadata: {
          labels: { "metatron.therubyist.org/name": "test" },
          name: "test"
        },
        spec: {
          gatewayClassName: "envoy-gateway",
          listeners: []
        }
      }
    end

    it "produces a hash" do
      expect(gateway.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(gateway.render).to eq(rendered_gateway)
    end
  end

  describe "for complex gateways (keyword form)" do
    let(:gateway) do
      gw = described_class.new("test", gateway_class_name: "traefik")
      gw.namespace = "production"
      gw.add_listener(name: "http", port: 80, protocol: "HTTP")
      gw.add_listener(
        name: "https-foo-bar",
        port: 443,
        protocol: "HTTPS",
        hostname: "foo.bar",
        tls: { mode: "Terminate", certificateRefs: [{ name: "foo-bar-tls" }] }
      )
      gw
    end

    let(:rendered_gateway) do
      {
        apiVersion: "gateway.networking.k8s.io/v1",
        kind: "Gateway",
        metadata: {
          labels: { "metatron.therubyist.org/name": "test" },
          name: "test",
          namespace: "production"
        },
        spec: {
          gatewayClassName: "traefik",
          listeners: [
            { name: "http", port: 80, protocol: "HTTP" },
            {
              name: "https-foo-bar",
              port: 443,
              protocol: "HTTPS",
              hostname: "foo.bar",
              tls: { mode: "Terminate", certificateRefs: [{ name: "foo-bar-tls" }] }
            }
          ]
        }
      }
    end

    it "produces a hash" do
      expect(gateway.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(gateway.render).to eq(rendered_gateway)
    end
  end

  describe "for complex gateways (object form)" do
    let(:gateway) do
      gw = described_class.new("test", gateway_class_name: "traefik")
      gw.namespace = "production"
      http_listener = Metatron::Templates::Gateway::Listener.new("http", port: 80, protocol: "HTTP")
      gw.add_listener(http_listener)
      gw.add_listener(
        Metatron::Templates::Gateway::Listener.new(
          "https-foo-bar",
          port: 443,
          protocol: "HTTPS",
          hostname: "foo.bar",
          tls: { mode: "Terminate", certificateRefs: [{ name: "foo-bar-tls" }] }
        )
      )
      gw
    end

    it "renders identically to the keyword form" do
      keyword_gw = described_class.new("test", gateway_class_name: "traefik")
      keyword_gw.namespace = "production"
      keyword_gw.add_listener(name: "http", port: 80, protocol: "HTTP")
      keyword_gw.add_listener(
        name: "https-foo-bar", port: 443, protocol: "HTTPS",
        hostname: "foo.bar",
        tls: { mode: "Terminate", certificateRefs: [{ name: "foo-bar-tls" }] }
      )
      expect(gateway.render).to eq(keyword_gw.render)
    end
  end
end
