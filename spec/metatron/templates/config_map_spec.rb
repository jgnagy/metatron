# frozen_string_literal: true

RSpec.describe Metatron::Templates::ConfigMap do
  let(:config_map) { described_class.new("test", { "some key" => "value" }) }

  let(:config_map_with_namespace) do
    template = described_class.new("test", { "some key" => "value" })
    template.namespace = "testnamespace"
    template
  end

  let(:rendered_config_map) do
    {
      apiVersion: "v1",
      kind: "ConfigMap",
      metadata: {
        name: "test",
        labels: { "metatron.therubyist.org/name": "test" }
      },
      data: {
        "some key" => "value"
      }
    }
  end

  let(:rendered_config_map_with_namespace) do
    {
      apiVersion: "v1",
      kind: "ConfigMap",
      metadata: {
        name: "test",
        namespace: "testnamespace",
        labels: { "metatron.therubyist.org/name": "test" }
      },
      data: {
        "some key" => "value"
      }
    }
  end

  it "produces a hash" do
    expect(config_map.render).to be_a(Hash)
  end

  it "renders properly" do
    expect(config_map.render).to eq(rendered_config_map)
  end

  it "renders properly with namespaces" do
    expect(config_map_with_namespace.render).to eq(rendered_config_map_with_namespace)
  end
end
