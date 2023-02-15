# frozen_string_literal: true

RSpec.describe Metatron::Templates::ReplicaSet do
  describe "for simple replica sets" do
    let(:replica_set) { described_class.new("test") }

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
              terminationGracePeriodSeconds: 60,
              containers: [
                {
                  image: "gcr.io/google_containers/pause",
                  imagePullPolicy: "IfNotPresent",
                  name: "app",
                  resources: {
                    limits: { cpu: "500m", memory: "512Mi" },
                    requests: { cpu: "10m", memory: "64Mi" }
                  },
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
      dep = described_class.new("test")
      dep.image = "some.registry/some/image:tag"
      dep.annotations = { "a.test/foo": "bar" }
      dep.additional_labels = { "app.kubernetes.io/part-of": "test-app" }
      dep.replicas = 10
      dep.additional_pod_labels = { thing: "swamp" }
      dep.security_context = { runAsUser: 1000, runAsGroup: 1000 }
      dep.volumes = [{ name: "tmpvol", emptyDir: {} }]
      dep.volume_mounts = [{ mountPath: "/tmp", name: "tmpvol" }]
      dep.env = { REDIS: "redis:6379", LOG_LEVEL: "DEBUG" }
      dep.ports = [{ name: "web", containerPort: 8080 }]
      dep.probes = {
        readinessProbe: {
          httpGet: { path: "/ping", port: "web" },
          periodSeconds: 5,
          failureThreshold: 3
        }
      }
      dep.container_security_context = {
        privileged: false,
        runAsNonRoot: true,
        readOnlyRootFilesystem: true,
        capabilities: { drop: ["all"] }
      }
      dep
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
              terminationGracePeriodSeconds: 60,
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
