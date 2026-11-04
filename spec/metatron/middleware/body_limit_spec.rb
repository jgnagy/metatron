# frozen_string_literal: true

require "rack"
require "rack/test"

RSpec.describe Metatron::Middleware::BodyLimit do
  include Rack::Test::Methods

  let(:max_bytes) { 32 }
  let(:inner_app) do
    lambda do |env|
      [200, { "content-type" => "application/json" }, [env["rack.input"].read]]
    end
  end
  let(:app) { Rack::Lint.new(described_class.new(inner_app, max_bytes: max_bytes)) }

  around do |example|
    original = ENV.fetch(described_class::MAX_BYTES_ENV_VAR, nil)
    ENV.delete(described_class::MAX_BYTES_ENV_VAR)
    example.run
    ENV[described_class::MAX_BYTES_ENV_VAR] = original
  end

  it "passes a body within the limit through untouched" do
    post "/", "hello"
    expect(last_response.status).to eq(200)
  end

  it "hands the body to the application intact" do
    post "/", "hello"
    expect(last_response.body).to eq("hello")
  end

  it "rejects a body over the limit" do
    post "/", "x" * 64
    expect(last_response.status).to eq(413)
  end

  it "returns a JSON problem document when the body is too large" do
    post "/", "x" * 64
    expect(last_response.headers["content-type"]).to eq("application/problem+json")
  end

  it "describes the failure in the problem document" do
    post "/", "x" * 64
    expect(JSON.parse(last_response.body)).to include("status" => 413,
                                                      "title" => "Payload Too Large")
  end

  it "rejects a request whose content length exceeds the limit" do
    post "/", "x" * 64, { "CONTENT_LENGTH" => "64" }
    expect(last_response.status).to eq(413)
  end

  it "accepts a body exactly at the limit" do
    post "/", "x" * max_bytes
    expect(last_response.status).to eq(200)
  end

  it "rejects an oversized body that understates its content length" do
    env = Rack::MockRequest.env_for("/", method: "POST", input: "x" * 64)
    env.delete("CONTENT_LENGTH")
    status, = described_class.new(inner_app, max_bytes: max_bytes).call(env)
    expect(status).to eq(413)
  end

  it "does not call the application when the body is too large" do
    called = false
    app = described_class.new(->(_env) { called = true }, max_bytes: max_bytes)
    env = Rack::MockRequest.env_for("/", method: "POST", input: "x" * 64)
    app.call(env)
    expect(called).to be(false)
  end

  context "when no limit is configured" do
    let(:app) { Rack::Lint.new(described_class.new(inner_app)) }

    it "defaults to a 1 MiB cap" do
      expect(described_class::DEFAULT_MAX_BYTES).to eq(1024 * 1024)
    end

    it "accepts a body larger than a small custom limit" do
      post "/", "x" * 1024
      expect(last_response.status).to eq(200)
    end
  end

  context "when the limit comes from the environment" do
    let(:app) { Rack::Lint.new(described_class.new(inner_app)) }

    around do |example|
      original = ENV.fetch(described_class::MAX_BYTES_ENV_VAR, nil)
      ENV[described_class::MAX_BYTES_ENV_VAR] = max_bytes.to_s
      example.run
      ENV[described_class::MAX_BYTES_ENV_VAR] = original
    end

    it "rejects a body over the configured limit" do
      post "/", "x" * 64
      expect(last_response.status).to eq(413)
    end
  end
end
