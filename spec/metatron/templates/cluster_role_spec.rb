# frozen_string_literal: true

RSpec.describe Metatron::Templates::ClusterRole do
  describe "for typical cluster roles" do
    let(:cluster_role) do
      resource = described_class.new("secret-reader")
      resource.rules = [
        { apiGroups: [""], resources: ["secrets"], verbs: %w[get watch list] }
      ]
      resource
    end

    let(:rendered_cluster_role) do
      {
        apiVersion: "rbac.authorization.k8s.io/v1",
        kind: "ClusterRole",
        metadata: {
          name: "secret-reader",
          labels: { "metatron.therubyist.org/name": "secret-reader" }
        },
        rules: [
          { apiGroups: [""], resources: ["secrets"], verbs: %w[get watch list] }
        ]
      }
    end

    it "produces a hash" do
      expect(cluster_role.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(cluster_role.render).to eq(rendered_cluster_role)
    end
  end

  describe "with an aggregation rule" do
    let(:cluster_role) do
      resource = described_class.new("monitoring")
      resource.aggregation_rule = {
        clusterRoleSelectors: [
          { matchLabels: { "rbac.example.com/aggregate-to-monitoring": "true" } }
        ]
      }
      resource
    end

    let(:rendered_cluster_role) do
      {
        apiVersion: "rbac.authorization.k8s.io/v1",
        kind: "ClusterRole",
        metadata: {
          name: "monitoring",
          labels: { "metatron.therubyist.org/name": "monitoring" }
        },
        aggregationRule: {
          clusterRoleSelectors: [
            { matchLabels: { "rbac.example.com/aggregate-to-monitoring": "true" } }
          ]
        },
        rules: []
      }
    end

    it "produces a hash" do
      expect(cluster_role.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(cluster_role.render).to eq(rendered_cluster_role)
    end
  end
end
