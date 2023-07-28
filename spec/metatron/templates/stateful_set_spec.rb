# frozen_string_literal: true

RSpec.describe Metatron::Templates::StatefulSet do
  describe "for simple stateful sets" do
    let(:stateful_set) do
      stateful_set = described_class.new("test")
      stateful_set.containers << Metatron::Templates::Container.new("app")
      stateful_set
    end

    let(:rendered_stateful_set) do
      {
        apiVersion: "apps/v1",
        kind: "StatefulSet",
        metadata: { labels: { "metatron.therubyist.org/name": "test" }, name: "test" },
        spec: {
          enableServiceLinks: true,
          replicas: 1,
          selector: { matchLabels: { "metatron.therubyist.org/name": "test" } },
          serviceName: "test",
          strategy: { rollingUpdate: { maxSurge: 2, maxUnavailable: 0 }, type: "RollingUpdate" },
          template: {
            metadata: { labels: { "metatron.therubyist.org/name": "test" } },
            spec: {
              containers: [
                {
                  image: "gcr.io/google_containers/pause",
                  imagePullPolicy: "IfNotPresent",
                  name: "app",
                  stdin: true,
                  tty: true
                }
              ]
            }
          }
        }
      }
    end

    it "produces a hash" do
      expect(stateful_set.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(stateful_set.render).to eq(rendered_stateful_set)
    end
  end

  describe "for complex stateful sets" do
    let(:stateful_set) do
      stateful_set = described_class.new("test")

      container = Metatron::Templates::Container.new("app")
      container.image = "some.registry/some/image:tag"
      container.envfrom = ["foo"]
      container.resources = {
        limits: { cpu: "500m", memory: "512Mi" },
        requests: { cpu: "10m", memory: "64Mi" }
      }

      stateful_set.containers << container
      stateful_set.namespace = "atestnamespace"
      stateful_set.replicas = 5
      stateful_set.termination_grace_period_seconds = 10
      stateful_set.additional_pod_labels = { foo: "bar" }
      stateful_set.service_name = "a-test"
      stateful_set.persistent_volume_claims = [
        Metatron::Templates::PersistentVolumeClaim.new("test", storage_class: "test",
                                                               storage: "1Gi").render
      ]
      stateful_set
    end

    let(:rendered_stateful_set) do
      {
        apiVersion: "apps/v1",
        kind: "StatefulSet",
        metadata: {
          labels: { "metatron.therubyist.org/name": "test" },
          name: "test",
          namespace: "atestnamespace"
        },
        spec: {
          enableServiceLinks: true,
          replicas: 5,
          selector: { matchLabels: { "metatron.therubyist.org/name": "test", foo: "bar" } },
          serviceName: "a-test",
          strategy: { rollingUpdate: { maxSurge: 2, maxUnavailable: 0 }, type: "RollingUpdate" },
          template: {
            metadata: { labels: { "metatron.therubyist.org/name": "test", foo: "bar" } },
            spec: {
              containers: [
                {
                  image: "some.registry/some/image:tag",
                  imagePullPolicy: "IfNotPresent",
                  name: "app",
                  resources: {
                    limits: { cpu: "500m", memory: "512Mi" },
                    requests: { cpu: "10m", memory: "64Mi" }
                  },
                  stdin: true,
                  tty: true,
                  envFrom: [{ secretRef: { name: "foo" } }]
                }
              ],
              terminationGracePeriodSeconds: 10
            }
          }
        },
        volumeClaimTemplates: [
          {
            apiVersion: "v1",
            kind: "PersistentVolumeClaim",
            metadata: {
              name: "test",
              labels: { "metatron.therubyist.org/name": "test" }
            },
            spec: {
              accessModes: ["ReadWriteOnce"],
              storageClassName: "test",
              resources: {
                requests: {
                  storage: "1Gi"
                }
              }
            }
          }
        ]
      }
    end

    it "produces a hash" do
      expect(stateful_set.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(stateful_set.render).to eq(rendered_stateful_set)
    end
  end
end
