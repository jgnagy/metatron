# frozen_string_literal: true

require "metatron"

RSpec.describe Metatron::Template do
  describe "for basic template behaviours" do
    it "uses the class name if it is a template" do
      actual_kind = Metatron::Templates::ConfigMap.new("test").render[:kind]
      expect(actual_kind).to eq("ConfigMap")
    end

    it "uses the closest ancestor's name if it inherits a template" do
      actual_kind = FakeConfigMap.new("test", { "foo" => "bar" }).render[:kind]
      expect(actual_kind).to eq("ConfigMap")
    end

    it "uses the closest template's name even if it includes metatron concerns" do
      actual_kind = FakeConfigMapWithInclude.new("test", { "foo" => "bar" }).render[:kind]
      expect(actual_kind).to eq("ConfigMap")
    end

    it "includes initializers from the nearest ancestor" do
      thing = FakeConfigMap.new("test", { "foo" => "bar" })
      expect(thing.annotations).to eq({}) # this is set by Concerns::Annotated#annotated_initialize
    end

    it "uses the correct base label namespace" do
      actual_labels = FakeConfigMap.new("test", { "foo" => "bar" }).render[:metadata][:labels]
      expect(actual_labels.keys).to include(:"metatron.therubyist.org/name")
    end

    it "allows using a different base label namespace" do
      FakeConfigMap.label_namespace = "example.com"
      actual_labels = FakeConfigMap.new("test", { "foo" => "bar" }).render[:metadata][:labels]
      expect(actual_labels.keys).to include(:"example.com/name")
      FakeConfigMap.label_namespace = "metatron.therubyist.org"
    end

    it "allows setting the base labels directly on template instances" do
      cm = FakeConfigMap.new("test", { "foo" => "bar" })
      cm.base_labels = { "baz" => "qux" }
      actual_labels = cm.render[:metadata][:labels]
      expect(actual_labels).to eq({ "baz" => "qux" })
    end
  end
end

class FakeConfigMapWithInclude < Metatron::Templates::ConfigMap
  include Metatron::Templates::Concerns::Namespaced
end

class FakeConfigMap < Metatron::Templates::ConfigMap; end
