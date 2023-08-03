# frozen_string_literal: true

RSpec.describe Metatron::Templates::ServiceAccount do
  let(:service_account) do
    resource = described_class.new("test")
    resource.automount_service_account_token = true
    resource.namespace = "testnamespace"
    resource
  end

  let(:rendered_service_account) do
    {
      apiVersion: "v1",
      automountServiceAccountToken: true,
      kind: "ServiceAccount",
      metadata: {
        name: "test",
        namespace: "testnamespace",
        labels: { "metatron.therubyist.org/name": "test" }
      }
    }
  end

  it "produces a hash" do
    expect(service_account.render).to be_a(Hash)
  end

  it "renders properly" do
    expect(service_account.render).to eq(rendered_service_account)
  end
end
