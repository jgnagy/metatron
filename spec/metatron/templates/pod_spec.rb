# frozen_string_literal: true

RSpec.describe Metatron::Templates::Pod do
  describe "for simple pods" do
    let(:pod) do
      pod = described_class.new("test")
      pod.containers << Metatron::Templates::Container.new("app")
      pod
    end

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

      container = Metatron::Templates::Container.new("app")
      container.image = "some.registry/image:tag"
      container.image_pull_policy = "Always"
      container.volume_mounts = [{ mountPath: "/tmp", name: "tmpvol" }]
      container.env = { LOG_LEVEL: "DEBUG" }
      container.ports = [{ name: "web", containerPort: 9090 }]
      container.security_context = { readOnlyRootFilesystem: true }
      container.resources = {
        limits: { cpu: "500m", memory: "512Mi" },
        requests: { cpu: "10m", memory: "64Mi" }
      }

      pod.containers << container
      pod.annotations = { "a.test/foo": "bar" }
      pod.affinity = {
        nodeAffinity: {
          requiredDuringSchedulingIgnoredDuringExecution: {
            nodeSelectorTerms: [
              {
                matchExpressions: [{ key: "disktype", operator: "In", values: ["ssd"] }]
              }
            ]
          }
        }
      }
      pod.priority_class_name = "high-priority"
      pod.security_context = { runAsUser: 1001, runAsGroup: 1001 }
      pod.volumes = [{ name: "tmpvol", emptyDir: {} }]
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
          affinity: {
            nodeAffinity: {
              requiredDuringSchedulingIgnoredDuringExecution: {
                nodeSelectorTerms: [
                  {
                    matchExpressions: [{ key: "disktype", operator: "In", values: ["ssd"] }]
                  }
                ]
              }
            }
          },
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
          priorityClassName: "high-priority",
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
