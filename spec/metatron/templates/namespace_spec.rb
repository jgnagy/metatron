# frozen_string_literal: true

RSpec.describe Metatron::Templates::Namespace do
  let(:namespace) do
    namespace = described_class.new("testnamespace")
    namespace.annotations = { "foo.bar/test": "test" }
    namespace
  end

  let(:rendered_namespace) do
    {
      apiVersion: "v1",
      kind: "Namespace",
      metadata: {
        annotations: { "foo.bar/test": "test" },
        labels: { "metatron.therubyist.org/name": "testnamespace" },
        name: "testnamespace"
      }
    }
  end

  it "produces a hash" do
    expect(namespace.render).to be_a(Hash)
  end

  it "renders properly" do
    expect(namespace.render).to eq(rendered_namespace)
  end
end
