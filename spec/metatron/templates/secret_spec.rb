# frozen_string_literal: true

RSpec.describe Metatron::Templates::Secret do
  let(:secret) { described_class.new("test", { "some secret" => "value" }) }

  let(:rendered_secret) do
    {
      apiVersion: "v1",
      kind: "Secret",
      metadata: {
        name: "test",
        labels: { "metatron.therubyist.org/name": "test" }
      },
      type: "Opaque",
      stringData: {
        "some secret" => "value"
      }
    }
  end

  it "produces a hash" do
    expect(secret.render).to be_a(Hash)
  end

  it "renders properly" do
    expect(secret.render).to eq(rendered_secret)
  end
end
