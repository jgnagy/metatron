# frozen_string_literal: true

RSpec.describe Metatron::Templates::ResourceQuota do
  describe "for simple resourcequotas" do
    let(:resource_quota) do
      resource = described_class.new("testresourcequota")
      resource
    end

    let(:rendered_resourcequota) do
      {
        apiVersion: "v1",
        kind: "ResourceQuota",
        metadata: {
          name: "testresourcequota",
          labels: { "metatron.therubyist.org/name": "testresourcequota" }
        }
      }
    end

    it "produces a hash" do
      expect(resource_quota.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(resource_quota.render).to eq(rendered_resourcequota)
    end
  end

  describe "for complex resourcequotas" do
    let(:resource_quota) do
      resource = described_class.new("testresourcequota")
      resource.spec = { hard: { cpus: "2" } }
      resource
    end

    let(:rendered_resourcequota) do
      {
        apiVersion: "v1",
        kind: "ResourceQuota",
        metadata: {
          name: "testresourcequota",
          labels: { "metatron.therubyist.org/name": "testresourcequota" }
        },
        spec: { hard: { cpus: "2" } }
      }
    end

    it "produces a hash" do
      expect(resource_quota.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(resource_quota.render).to eq(rendered_resourcequota)
    end
  end
end
