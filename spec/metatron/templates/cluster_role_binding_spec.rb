# frozen_string_literal: true

RSpec.describe Metatron::Templates::ClusterRoleBinding do
  let(:cluster_role) do
    resource = Metatron::Templates::ClusterRole.new("secret-reader")
    resource.rules = [
      { apiGroups: [""], resources: ["secrets"], verbs: %w[get watch list] }
    ]
    resource
  end

  let(:cluster_role_binding) do
    resource = described_class.new("secret-reader-binding", cluster_role)
    resource.subjects = [
      { kind: "ServiceAccount", name: "default", namespace: "kube-system" }
    ]
    resource
  end

  let(:rendered_cluster_role_binding) do
    {
      apiVersion: "rbac.authorization.k8s.io/v1",
      kind: "ClusterRoleBinding",
      metadata: {
        name: "secret-reader-binding",
        labels: { "metatron.therubyist.org/name": "secret-reader-binding" }
      },
      roleRef: {
        kind: "ClusterRole",
        apiGroup: "rbac.authorization.k8s.io",
        name: "secret-reader"
      },
      subjects: [
        { kind: "ServiceAccount", name: "default", namespace: "kube-system" }
      ]
    }
  end

  it "produces a hash" do
    expect(cluster_role_binding.render).to be_a(Hash)
  end

  it "renders properly" do
    expect(cluster_role_binding.render).to eq(rendered_cluster_role_binding)
  end
end
