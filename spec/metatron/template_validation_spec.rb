# frozen_string_literal: true

RSpec.describe Metatron::Template do
  describe "#initialize" do
    it "raises ArgumentError if name is nil" do
      expect { described_class.new(nil) }.to raise_error(
        ArgumentError, /name must be a non-empty string/
      )
    end

    it "raises ArgumentError if name is an empty string" do
      expect { described_class.new("") }.to raise_error(
        ArgumentError, /name must be a non-empty string/
      )
    end

    it "raises ArgumentError if name is only whitespace" do
      expect { described_class.new("  ") }.to raise_error(
        ArgumentError, /name must be a non-empty string/
      )
    end

    it "raises ArgumentError if name is not a string" do
      expect { described_class.new(123) }.to raise_error(
        ArgumentError, /name must be a non-empty string/
      )
    end

    it "works normally with a valid string name" do
      template = described_class.new("valid-name")
      expect(template.name).to eq("valid-name")
    end
  end
end
