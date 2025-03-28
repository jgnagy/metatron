# frozen_string_literal: true

RSpec.describe Metatron::Templates::Secret do
  describe "using legacy unnamed constructor with string_data" do
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
        data: { "some secret" => "dmFsdWU=" } # Base64 encoded "value"
      }
    end

    it "produces a hash" do
      expect(secret.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(secret.render).to eq(rendered_secret)
    end
  end

  describe "using named constructor with string_data" do
    let(:secret) do
      described_class.new("test", string_data: { "some secret" => "value" })
    end

    let(:rendered_secret) do
      {
        apiVersion: "v1",
        kind: "Secret",
        metadata: {
          name: "test",
          labels: { "metatron.therubyist.org/name": "test" }
        },
        type: "Opaque",
        data: { "some secret" => "dmFsdWU=" } # Base64 encoded "value"
      }
    end

    it "produces a hash" do
      expect(secret.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(secret.render).to eq(rendered_secret)
    end
  end

  describe "using named constructor with data" do
    let(:secret) do
      described_class.new("test", data: { "some secret" => "b3RoZXIgdmFsdWU=" })
    end

    let(:rendered_secret) do
      {
        apiVersion: "v1",
        kind: "Secret",
        metadata: {
          name: "test",
          labels: { "metatron.therubyist.org/name": "test" }
        },
        type: "Opaque",
        data: { "some secret" => "b3RoZXIgdmFsdWU=" } # Base64 encoded "other value"
      }
    end

    it "produces a hash" do
      expect(secret.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(secret.render).to eq(rendered_secret)
    end
  end

  describe "using named constructor with both string_data and data" do
    let(:secret) do
      described_class.new(
        "test",
        data: { "some secret" => "b3RoZXIgdmFsdWU=" }, # should prefer this
        string_data: { "some secret" => "value" }
      )
    end

    let(:rendered_secret) do
      {
        apiVersion: "v1",
        kind: "Secret",
        metadata: {
          name: "test",
          labels: { "metatron.therubyist.org/name": "test" }
        },
        type: "Opaque",
        data: { "some secret" => "b3RoZXIgdmFsdWU=" } # Base64 encoded "other value"
      }
    end

    it "produces a hash" do
      expect(secret.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(secret.render).to eq(rendered_secret)
    end
  end

  describe "using no data or string_data in constructor, applying string_data later" do
    let(:secret) do
      r = described_class.new("test")
      r.string_data = { "some secret" => "value" }
      r
    end

    let(:rendered_secret) do
      {
        apiVersion: "v1",
        kind: "Secret",
        metadata: {
          name: "test",
          labels: { "metatron.therubyist.org/name": "test" }
        },
        type: "Opaque",
        data: { "some secret" => "dmFsdWU=" } # Base64 encoded "value"
      }
    end

    it "produces a hash" do
      expect(secret.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(secret.render).to eq(rendered_secret)
    end
  end
end
