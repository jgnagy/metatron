# frozen_string_literal: true

RSpec.describe Metatron::Templates::Deployment do
  describe "for simple deployments" do
    let(:deployment) { described_class.new("test") }

    let(:rendered_deployment) do
      {
        apiVersion: "apps/v1",
        kind: "Deployment",
        metadata: { labels: { "metatron.therubyist.org/name": "test" }, name: "test" },
        spec: {
          replicas: 2,
          selector: { matchLabels: { "metatron.therubyist.org/name": "test" } },
          strategy: { rollingUpdate: { maxSurge: 2, maxUnavailable: 0 }, type: "RollingUpdate" },
          template: {
            metadata: { labels: { "metatron.therubyist.org/name": "test" } },
            spec: {
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
      expect(deployment.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(deployment.render).to eq(rendered_deployment)
    end
  end

  describe "for complex deployments" do
    let(:deployment) do
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

    let(:rendered_deployment) do
      {
        apiVersion: "apps/v1",
        kind: "Deployment",
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
          strategy: { rollingUpdate: { maxSurge: 2, maxUnavailable: 0 }, type: "RollingUpdate" },
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
      expect(deployment.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(deployment.render).to eq(rendered_deployment)
    end
  end
end
