# frozen_string_literal: true

RSpec.describe Metatron::Templates::ConfigMap do
  let(:config_map) { described_class.new("test", { "some key" => "value" }) }

  let(:config_map_with_all_features) do
    template = described_class.new("test", { "some key" => "value" })
    template.namespace = "testnamespace"
    template.annotations[:"some.annotation"] = "value"
    template.additional_labels[:"some.label"] = "othervalue"
    template.immutable = true
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

  let(:rendered_config_map_with_all_features) do
    {
      apiVersion: "v1",
      kind: "ConfigMap",
      metadata: {
        name: "test",
        namespace: "testnamespace",
        annotations: { "some.annotation": "value" },
        labels: {
          "metatron.therubyist.org/name": "test",
          "some.label": "othervalue"
        }
      },
      data: {
        "some key" => "value"
      },
      immutable: true
    }
  end

  it "produces a hash" do
    expect(config_map.render).to be_a(Hash)
  end

  it "renders properly" do
    expect(config_map.render).to eq(rendered_config_map)
  end

  it "renders properly with all features in use" do
    expect(config_map_with_all_features.render).to eq(rendered_config_map_with_all_features)
  end
end
