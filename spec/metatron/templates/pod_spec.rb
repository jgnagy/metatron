# frozen_string_literal: true

RSpec.describe Metatron::Templates::Pod do
  describe "for simple pods" do
    let(:pod) { described_class.new("test") }

    let(:rendered_pod) do
      {
        apiVersion: "v1",
        kind: "Pod",
        metadata: { labels: { "metatron.therubyist.org/name": "test" }, name: "test" },
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
    end

    it "produces a hash" do
      expect(pod.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(pod.render).to eq(rendered_pod)
    end
  end

  describe "for complex pods" do
    let(:pod) do
      pod = described_class.new("test")
      pod.image = "some.registry/image:tag"
      pod.image_pull_policy = "Always"
      pod.annotations = { "a.test/foo": "bar" }
      pod.security_context = { runAsUser: 1001, runAsGroup: 1001 }
      pod.volumes = [{ name: "tmpvol", emptyDir: {} }]
      pod.volume_mounts = [{ mountPath: "/tmp", name: "tmpvol" }]
      pod.env = { LOG_LEVEL: "DEBUG" }
      pod.ports = [{ name: "web", containerPort: 9090 }]
      pod.container_security_context = { readOnlyRootFilesystem: true }
      pod
    end

    let(:rendered_pod) do
      {
        apiVersion: "v1",
        kind: "Pod",
        metadata: {
          annotations: { "a.test/foo": "bar" },
          labels: { "metatron.therubyist.org/name": "test" },
          name: "test"
        },
        spec: {
          containers: [
            {
              env: [
                { name: :LOG_LEVEL, value: "DEBUG" }
              ],
              image: "some.registry/image:tag",
              imagePullPolicy: "Always",
              name: "app",
              ports: [{ containerPort: 9090, name: "web" }],
              resources: {
                limits: { cpu: "500m", memory: "512Mi" },
                requests: { cpu: "10m", memory: "64Mi" }
              },
              securityContext: { readOnlyRootFilesystem: true },
              stdin: true,
              tty: true,
              volumeMounts: [{ mountPath: "/tmp", name: "tmpvol" }]
            }
          ],
          securityContext: { runAsGroup: 1001, runAsUser: 1001 },
          volumes: [{ emptyDir: {}, name: "tmpvol" }]
        }
      }
    end

    it "produces a hash" do
      expect(pod.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(pod.render).to eq(rendered_pod)
    end
  end
end
