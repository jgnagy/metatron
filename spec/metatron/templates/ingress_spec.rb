# frozen_string_literal: true

RSpec.describe Metatron::Templates::Ingress do
  describe "for simple ingresses" do
    let(:ingress) { described_class.new("test") }

    let(:rendered_ingress) do
      {
        apiVersion: "networking.k8s.io/v1",
        kind: "Ingress",
        metadata: {
          annotations: { "kubernetes.io/ingress.class": "nginx" },
          labels: { "metatron.therubyist.org/name": "test" },
          name: "test"
        },
        spec: {}
      }
    end

    it "produces a hash" do
      expect(ingress.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(ingress.render).to eq(rendered_ingress)
    end
  end

  describe "for complex ingresses" do
    let(:ingress) do
      ingress = described_class.new("test", "traefik")
      ingress.add_rule("foo.bar": { "some-service": "some-port" })
      ingress.add_rule(
        host: "other.host", service: { name: "other-service", port: "other-port" }
      )
      ingress.add_tls("foo.bar", "other.host")
      ingress.additional_annotations = {
        "cert-manager.io/cluster-issuer": "letsencrypt",
        "cert-manager.io/acme-challenge-type": "http01"
      }
      ingress
    end

    let(:rendered_ingress) do
      {
        apiVersion: "networking.k8s.io/v1",
        kind: "Ingress",
        metadata: {
          annotations: {
            "kubernetes.io/ingress.class": "traefik",
            "cert-manager.io/cluster-issuer": "letsencrypt",
            "cert-manager.io/acme-challenge-type": "http01"
          },
          labels: { "metatron.therubyist.org/name": "test" },
          name: "test"
        },
        spec: {
          rules: [
            {
              host: "foo.bar",
              http: {
                paths: [
                  {
                    pathType: "Prefix",
                    path: "/",
                    backend: {
                      service: {
                        name: "some-service",
                        port: { name: "some-port" }
                      }
                    }
                  }
                ]
              }
            },
            {
              host: "other.host",
              http: {
                paths: [
                  {
                    pathType: "Prefix",
                    path: "/",
                    backend: {
                      service: {
                        name: "other-service",
                        port: { name: "other-port" }
                      }
                    }
                  }
                ]
              }
            }
          ],
          tls: [
            { hosts: ["foo.bar", "other.host"], secretName: "foo-bar-tls" }
          ]
        }
      }
    end

    it "produces a hash" do
      expect(ingress.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(ingress.render).to eq(rendered_ingress)
    end
  end
end
