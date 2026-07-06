# frozen_string_literal: true

RSpec.describe Metatron::Templates::HorizontalPodAutoscaler do
  describe "for simple horizontal pod autoscalers" do
    let(:hpa) do
      described_class.new("test")
    end

    let(:rendered_hpa) do
      {
        apiVersion: "autoscaling/v2",
        kind: "HorizontalPodAutoscaler",
        metadata: { labels: { "metatron.therubyist.org/name": "test" }, name: "test" },
        spec: {
          scaleTargetRef: { apiVersion: "apps/v1", kind: "Deployment", name: "test" },
          maxReplicas: 1
        }
      }
    end

    it "produces a hash" do
      expect(hpa.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(hpa.render).to eq(rendered_hpa)
    end
  end

  describe "for complex horizontal pod autoscalers" do
    let(:hpa) do
      h = described_class.new("test")
      h.min_replicas = 2
      h.max_replicas = 10
      h.scale_target_ref = { apiVersion: "apps/v1", kind: "StatefulSet", name: "test" }
      h.metrics = [{
        type: "Resource",
        resource: {
          name: "cpu",
          target: { type: "Utilization", averageUtilization: 80 }
        }
      }]
      h.behavior = { scaleDown: { stabilizationWindowSeconds: 300 } }
      h.annotations = { "a.test/foo": "bar" }
      h.additional_labels = { "app.kubernetes.io/part-of": "test-app" }
      h.namespace = "production"
      h
    end

    let(:rendered_hpa) do
      {
        apiVersion: "autoscaling/v2",
        kind: "HorizontalPodAutoscaler",
        metadata: {
          annotations: { "a.test/foo": "bar" },
          labels: {
            "app.kubernetes.io/part-of": "test-app",
            "metatron.therubyist.org/name": "test"
          },
          name: "test",
          namespace: "production"
        },
        spec: {
          behavior: { scaleDown: { stabilizationWindowSeconds: 300 } },
          maxReplicas: 10,
          metrics: [
            {
              type: "Resource",
              resource: {
                name: "cpu",
                target: { type: "Utilization", averageUtilization: 80 }
              }
            }
          ],
          minReplicas: 2,
          scaleTargetRef: { apiVersion: "apps/v1", kind: "StatefulSet", name: "test" }
        }
      }
    end

    it "produces a hash" do
      expect(hpa.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(hpa.render).to eq(rendered_hpa)
    end
  end
end
