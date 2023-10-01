# frozen_string_literal: true

RSpec.describe Metatron::Templates::Role do
  describe "for typical roles" do
    let(:role) do
      resource = described_class.new("secret-reader")
      resource.rules = [
        { apiGroups: [""], resources: ["secrets"], verbs: %w[get watch list] }
      ]
      resource
    end

    let(:rendered_role) do
      {
        apiVersion: "rbac.authorization.k8s.io/v1",
        kind: "Role",
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
      expect(role.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(role.render).to eq(rendered_role)
    end
  end
end
