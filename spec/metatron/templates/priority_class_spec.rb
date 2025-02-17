# frozen_string_literal: true

RSpec.describe Metatron::Templates::PriorityClass do
  let(:priority_class) do
    priority_class = described_class.new("test-class")
    priority_class.annotations = { "foo.bar/test": "test" }
    priority_class.value = 10_000
    priority_class
  end

  let(:rendered_priority_class) do
    {
      apiVersion: "scheduling.k8s.io/v1",
      kind: "PriorityClass",
      globalDefault: false,
      metadata: {
        annotations: { "foo.bar/test": "test" },
        labels: { "metatron.therubyist.org/name": "test-class" },
        name: "test-class"
      },
      value: 10_000
    }
  end

  it "produces a hash" do
    expect(priority_class.render).to be_a(Hash)
  end

  it "renders properly" do
    expect(priority_class.render).to eq(rendered_priority_class)
  end
end
