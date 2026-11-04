# frozen_string_literal: true

require "rack"
require "rack/test"

RSpec.describe Metatron::Middleware::Auth do
  include Rack::Test::Methods

  let(:secret) { "correct-horse-battery-staple" }
  let(:inner_app) do
    lambda do |_env|
      [200, { "content-type" => "application/json" }, [{ ok: true }.to_json]]
    end
  end
  let(:app) { Rack::Lint.new(described_class.new(inner_app, secret: secret)) }

  around do |example|
    original = ENV.fetch(described_class::SECRET_ENV_VAR, nil)
    ENV.delete(described_class::SECRET_ENV_VAR)
    example.run
    ENV[described_class::SECRET_ENV_VAR] = original
  end

  context "when a secret is configured" do
    it "passes a request with a valid token through" do
      post "/", {}, { "HTTP_AUTHORIZATION" => "Bearer #{secret}" }
      expect(last_response.status).to eq(200)
    end

    it "passes the request body through untouched" do
      post "/", {}, { "HTTP_AUTHORIZATION" => "Bearer #{secret}" }
      expect(last_response.body).to eq({ ok: true }.to_json)
    end

    it "rejects a request with an invalid token" do
      post "/", {}, { "HTTP_AUTHORIZATION" => "Bearer wrong-token" }
      expect(last_response.status).to eq(401)
    end

    it "rejects a request without an Authorization header" do
      post "/"
      expect(last_response.status).to eq(401)
    end

    it "rejects a request using a different scheme" do
      post "/", {}, { "HTTP_AUTHORIZATION" => "Basic #{secret}" }
      expect(last_response.status).to eq(401)
    end

    it "rejects a request with an empty token" do
      post "/", {}, { "HTTP_AUTHORIZATION" => "Bearer " }
      expect(last_response.status).to eq(401)
    end

    it "rejects a token of a different length" do
      post "/", {}, { "HTTP_AUTHORIZATION" => "Bearer #{secret}extra" }
      expect(last_response.status).to eq(401)
    end

    it "returns a JSON problem document when unauthorized" do
      post "/", {}, { "HTTP_AUTHORIZATION" => "Bearer wrong-token" }
      expect(last_response.headers["content-type"]).to eq("application/problem+json")
    end

    it "describes the failure in the problem document" do
      post "/", {}, { "HTTP_AUTHORIZATION" => "Bearer wrong-token" }
      expect(JSON.parse(last_response.body)).to include("status" => 401, "title" => "Unauthorized")
    end

    it "sends a Bearer challenge when unauthorized" do
      post "/"
      expect(last_response.headers["www-authenticate"]).to include("Bearer")
    end

    it "never echoes the secret back to the caller" do
      post "/", {}, { "HTTP_AUTHORIZATION" => "Bearer #{secret}" }
      expect(last_response.body).not_to include(secret)
    end

    it "compares the token with a constant-time comparison" do
      allow(Rack::Utils).to receive(:secure_compare).and_call_original
      post "/", {}, { "HTTP_AUTHORIZATION" => "Bearer #{secret}" }
      expect(Rack::Utils).to have_received(:secure_compare).with(secret, secret)
    end
  end

  context "when no secret is configured" do
    let(:app) { Rack::Lint.new(described_class.new(inner_app)) }

    it "passes requests through untouched" do
      post "/"
      expect(last_response.status).to eq(200)
    end

    it "does not require an Authorization header" do
      post "/", {}, { "HTTP_AUTHORIZATION" => "Bearer nonsense" }
      expect(last_response.status).to eq(200)
    end
  end

  context "when the secret comes from the environment" do
    let(:app) { Rack::Lint.new(described_class.new(inner_app)) }

    around do |example|
      original = ENV.fetch(described_class::SECRET_ENV_VAR, nil)
      ENV[described_class::SECRET_ENV_VAR] = secret
      example.run
      ENV[described_class::SECRET_ENV_VAR] = original
    end

    it "passes a request with the environment secret through" do
      post "/", {}, { "HTTP_AUTHORIZATION" => "Bearer #{secret}" }
      expect(last_response.status).to eq(200)
    end

    it "rejects a request without a token" do
      post "/"
      expect(last_response.status).to eq(401)
    end

    it "rejects a request with the wrong token" do
      post "/", {}, { "HTTP_AUTHORIZATION" => "Bearer wrong-token" }
      expect(last_response.status).to eq(401)
    end
  end
end
