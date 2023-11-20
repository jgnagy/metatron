# frozen_string_literal: true

require "rack/test"

RSpec.describe Metatron::Controllers::Ping do
  include Rack::Test::Methods

  let(:app) { Rack::Lint.new(described_class.new) }

  it "returns a 200 status" do
    get "/"
    expect(last_response.status).to eq(200)
  end

  it "returns a JSON response body" do
    get "/"
    expect(last_response.body).to eq({ status: "up" }.to_json)
  end

  it "responds with JSON content-type header" do
    get "/"
    expect(last_response.headers["content-type"]).to eq("application/json")
  end

  it "returns a 403 status for invalid request methods" do
    post "/"
    expect(last_response.status).to eq(403)
  end

  it "returns allowed request methods on options request" do
    options "/"
    expect(last_response.headers["access-control-allow-methods"]).to eq(["GET"])
  end
end
