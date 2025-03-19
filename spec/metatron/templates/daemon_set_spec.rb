# frozen_string_literal: true

RSpec.describe Metatron::Templates::DaemonSet do
  describe "for simple daemon sets" do
    let(:daemon_set) do
      ds = described_class.new("test")

      container = Metatron::Templates::Container.new("app")

      ds.containers << container
      ds
    end

    let(:rendered_daemon_set) do
      {
        apiVersion: "apps/v1",
        kind: "DaemonSet",
        metadata: { labels: { "metatron.therubyist.org/name": "test" }, name: "test" },
        spec: {
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
      expect(daemon_set.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(daemon_set.render).to eq(rendered_daemon_set)
    end
  end

  describe "for complex daemon sets" do
    let(:daemon_set) do
      ds = described_class.new("test")

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

      ds.containers << container

      init_container = Metatron::Templates::Container.new("init")
      init_container.image = "some.registry/some/otherimage:tag"
      init_container.env = { LOG_LEVEL: "DEBUG" }

      ds.init_containers << init_container

      ds.annotations = { "a.test/foo": "bar" }
      ds.additional_labels = { "app.kubernetes.io/part-of": "test-app" }
      ds.namespace = "test-namespace"
      ds.additional_pod_labels = { them: "hills", thing: "swamp" }
      ds.additional_pod_match_labels = { thing: "swamp" }
      ds.security_context = { runAsUser: 1000, runAsGroup: 1000 }
      ds.volumes = [{ name: "tmpvol", emptyDir: {} }]

      ds
    end

    let(:rendered_daemon_set) do
      {
        apiVersion: "apps/v1",
        kind: "DaemonSet",
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
      expect(daemon_set.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(daemon_set.render).to eq(rendered_daemon_set)
    end
  end
end
