# frozen_string_literal: true

RSpec.describe Metatron::Templates::Deployment do
  describe "for simple deployments" do
    let(:deployment) do
      dep = described_class.new("test")

      container = Metatron::Templates::Container.new("app")

      dep.containers << container
      dep
    end

    let(:rendered_deployment) do
      {
        apiVersion: "apps/v1",
        kind: "Deployment",
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
      expect(deployment.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(deployment.render).to eq(rendered_deployment)
    end
  end

  describe "for complex deployments" do
    let(:deployment) do
      dep = described_class.new("test")

      container = Metatron::Templates::Container.new("app")
      container.image = "some.registry/some/image:tag"
      container.volume_mounts = [{ mountPath: "/tmp", name: "tmpvol" }]
      container.env = { REDIS: "redis:6379", LOG_LEVEL: "DEBUG" }
      container.ports = [{ name: "web", containerPort: 8080 }]
      container.resources = {
        limits: { cpu: "500m", memory: "512Mi" },
        requests: { cpu: "10m", memory: "64Mi" }
      }
      container.probes = {
        readinessProbe: {
          httpGet: { path: "/ping", port: "web" },
          periodSeconds: 5,
          failureThreshold: 3
        }
      }
      container.security_context = {
        privileged: false,
        runAsNonRoot: true,
        readOnlyRootFilesystem: true,
        capabilities: { drop: ["all"] }
      }

      dep.containers << container

      init_container = Metatron::Templates::Container.new("init")
      init_container.image = "some.registry/some/otherimage:tag"
      init_container.env = { LOG_LEVEL: "DEBUG" }

      dep.init_containers << init_container

      dep.annotations = { "a.test/foo": "bar" }
      dep.additional_labels = { "app.kubernetes.io/part-of": "test-app" }
      dep.namespace = "test-namespace"
      dep.replicas = 10
      dep.strategy = { type: "RollingUpdate", rollingUpdate: { maxSurge: 1, maxUnavailable: 0 } }
      dep.additional_pod_labels = { them: "hills", thing: "swamp" }
      dep.additional_pod_match_labels = { thing: "swamp" }
      dep.security_context = { runAsUser: 1000, runAsGroup: 1000 }
      dep.volumes = [{ name: "tmpvol", emptyDir: {} }]

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
          name: "test",
          namespace: "test-namespace"
        },
        spec: {
          replicas: 10,
          strategy: { type: "RollingUpdate", rollingUpdate: { maxSurge: 1, maxUnavailable: 0 } },
          selector: {
            matchLabels: { "metatron.therubyist.org/name": "test", thing: "swamp" }
          },
          template: {
            metadata: {
              labels: { "metatron.therubyist.org/name": "test", them: "hills", thing: "swamp" }
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
              initContainers: [
                {
                  image: "some.registry/some/otherimage:tag",
                  imagePullPolicy: "IfNotPresent",
                  name: "init",
                  stdin: true,
                  tty: true,
                  env: [{ name: :LOG_LEVEL, value: "DEBUG" }]
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
