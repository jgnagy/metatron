# frozen_string_literal: true

require "rack/test"

class TestController < Metatron::CompositeController
  def sync = { status: {}, children: [] }
end

class TestControllerWithEtags < Metatron::CompositeController
  def calculate_etag = "abcd1234"
  def sync = { status: {}, children: [] }
end

RSpec.describe Metatron::CompositeController do
  include Rack::Test::Methods

  context "when ETag support is NOT enabled" do
    def app = TestController

    it "returns a 200 OK for initial sync requests" do
      post "/sync", {}, "HTTP_ACCEPT" => "application/json", "Content-Type" => "application/json"
      expect(last_response.status).to eq(200)
    end

    it "returns the expected data for initial sync requests" do
      post "/sync", {}, "HTTP_ACCEPT" => "application/json", "Content-Type" => "application/json"
      expect(last_response.body).to eq({ status: {}, children: [] }.to_json)
    end

    it "does not provide an ETag header for initial sync requests" do
      post "/sync", {}, "HTTP_ACCEPT" => "application/json", "Content-Type" => "application/json"
      expect(last_response.headers.keys).not_to include("ETag")
    end

    it "returns a 200 for standard sync requests" do # rubocop:disable RSpec/ExampleLength
      post(
        "/sync",
        {},
        {
          "HTTP_ACCEPT" => "application/json",
          "HTTP_IF_NONE_MATCH" => "\"abcd1234\"", # This should be ignored
          "CONTENT_TYPE" => "application/json"
        }
      )
      expect(last_response.status).to eq(200)
    end

    it "provides the expected data for standard sync requests" do # rubocop:disable RSpec/ExampleLength
      post(
        "/sync",
        {},
        {
          "HTTP_ACCEPT" => "application/json",
          "HTTP_IF_NONE_MATCH" => "\"abcd1234\"", # This should be ignored
          "CONTENT_TYPE" => "application/json"
        }
      )
      expect(last_response.body).to eq({ status: {}, children: [] }.to_json)
    end
  end

  context "when ETag support is enabled" do
    def app = TestControllerWithEtags

    it "returns a 200 OK for initial sync requests" do
      post "/sync", {}, "HTTP_ACCEPT" => "application/json", "Content-Type" => "application/json"
      expect(last_response.status).to eq(200)
    end

    it "returns the expected data for initial sync requests" do
      post "/sync", {}, "HTTP_ACCEPT" => "application/json", "Content-Type" => "application/json"
      expect(last_response.body).to eq({ status: {}, children: [] }.to_json)
    end

    it "returns the expected ETag header for initial sync requests" do
      post "/sync", {}, "HTTP_ACCEPT" => "application/json", "Content-Type" => "application/json"
      expect(last_response.headers).to include("ETag" => "\"abcd1234\"")
    end

    it "returns a 412 for standard sync requests with ETag headers" do # rubocop:disable RSpec/ExampleLength
      post(
        "/sync",
        {},
        {
          "HTTP_ACCEPT" => "application/json",
          "HTTP_IF_NONE_MATCH" => "\"abcd1234\"",
          "CONTENT_TYPE" => "application/json"
        }
      )
      expect(last_response.status).to eq(412)
    end

    it "does not provide a body for standard sync requests with ETag headers" do # rubocop:disable RSpec/ExampleLength
      post(
        "/sync",
        {},
        {
          "HTTP_ACCEPT" => "application/json",
          "HTTP_IF_NONE_MATCH" => "\"abcd1234\"",
          "CONTENT_TYPE" => "application/json"
        }
      )
      expect(last_response.body).to be_empty
    end
  end
end
