# frozen_string_literal: true

RSpec.describe Metatron::Templates::ReplicaSet do
  describe "for simple replica sets" do
    let(:replica_set) do
      rs = described_class.new("test")
      rs.containers << Metatron::Templates::Container.new("app")
      rs
    end

    let(:rendered_replica_set) do
      {
        apiVersion: "apps/v1",
        kind: "ReplicaSet",
        metadata: { labels: { "metatron.therubyist.org/name": "test" }, name: "test" },
        spec: {
          replicas: 2,
          selector: { matchLabels: { "metatron.therubyist.org/name": "test" } },
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
      expect(replica_set.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(replica_set.render).to eq(rendered_replica_set)
    end
  end

  describe "for complex replica sets" do
    let(:replica_set) do
      rs = described_class.new("test")

      container = Metatron::Templates::Container.new("app")
      container.image = "some.registry/some/image:tag"
      container.volume_mounts = [{ mountPath: "/tmp", name: "tmpvol" }]
      container.env = { REDIS: "redis:6379", LOG_LEVEL: "DEBUG" }
      container.ports = [{ name: "web", containerPort: 8080 }]
      container.probes = {
        readinessProbe: {
          httpGet: { path: "/ping", port: "web" },
          periodSeconds: 5,
          failureThreshold: 3
        }
      }
      container.resources = {
        limits: { cpu: "500m", memory: "512Mi" },
        requests: { cpu: "10m", memory: "64Mi" }
      }
      container.security_context = {
        privileged: false,
        runAsNonRoot: true,
        readOnlyRootFilesystem: true,
        capabilities: { drop: ["all"] }
      }

      rs.containers << container
      rs.annotations = { "a.test/foo": "bar" }
      rs.additional_labels = { "app.kubernetes.io/part-of": "test-app" }
      rs.replicas = 10
      rs.additional_pod_labels = { thing: "swamp" }
      rs.security_context = { runAsUser: 1000, runAsGroup: 1000 }
      rs.volumes = [{ name: "tmpvol", emptyDir: {} }]

      rs
    end

    let(:rendered_replica_set) do
      {
        apiVersion: "apps/v1",
        kind: "ReplicaSet",
        metadata: {
          annotations: { "a.test/foo": "bar" },
          labels: {
            "app.kubernetes.io/part-of": "test-app",
            "metatron.therubyist.org/name": "test"
          },
          name: "test"
        },
        spec: {
          replicas: 10,
          selector: {
            matchLabels: { "metatron.therubyist.org/name": "test", thing: "swamp" }
          },
          template: {
            metadata: {
              labels: { "metatron.therubyist.org/name": "test", thing: "swamp" }
            },
            spec: {
              containers: [
                {
                  env: [
                    { name: :REDIS, value: "redis:6379" },
                    { name: :LOG_LEVEL, value: "DEBUG" }
                  ],
                  image: "some.registry/some/image:tag",
                  imagePullPolicy: "IfNotPresent",
                  name: "app",
                  ports: [{ containerPort: 8080, name: "web" }],
                  readinessProbe: {
                    failureThreshold: 3,
                    httpGet: { path: "/ping", port: "web" },
                    periodSeconds: 5
                  },
                  resources: {
                    limits: { cpu: "500m", memory: "512Mi" },
                    requests: { cpu: "10m", memory: "64Mi" }
                  },
                  securityContext: {
                    capabilities: { drop: ["all"] },
                    privileged: false,
                    readOnlyRootFilesystem: true,
                    runAsNonRoot: true
                  },
                  stdin: true,
                  tty: true,
                  volumeMounts: [{ mountPath: "/tmp", name: "tmpvol" }]
                }
              ],
              securityContext: { runAsGroup: 1000, runAsUser: 1000 },
              volumes: [{ emptyDir: {}, name: "tmpvol" }]
            }
          }
        }
      }
    end

    it "produces a hash" do
      expect(replica_set.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(replica_set.render).to eq(rendered_replica_set)
    end
  end
end
