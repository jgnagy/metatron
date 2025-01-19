# frozen_string_literal: true

RSpec.describe Metatron::Templates::LimitRange do
  describe "for simple limit ranges" do
    let(:limit_range) do
      limit_range = described_class.new("test-limit-range")
      limit_range.namespace = "test-namespace"
      limit_range.limits << {
        type: "Container",
        default: { cpu: "500m" },
        default_request: { cpu: "500m" },
        max: { cpu: "1" },
        min: { cpu: "100m" }
      }
      limit_range
    end

    let(:rendered_limit_range) do
      {
        apiVersion: "v1",
        kind: "LimitRange",
        metadata: {
          labels: { "metatron.therubyist.org/name": "test-limit-range" },
          name: "test-limit-range",
          namespace: "test-namespace"
        },
        spec: {
          limits: [
            {
              default: { cpu: "500m" },
              defaultRequest: { cpu: "500m" },
              max: { cpu: "1" },
              min: { cpu: "100m" },
              type: "Container"
            }
          ]
        }
      }
    end

    it "produces a hash" do
      expect(limit_range.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(limit_range.render).to eq(rendered_limit_range)
    end
  end
end
