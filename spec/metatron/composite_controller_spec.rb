# frozen_string_literal: true

require "rack/test"

class TestController < Metatron::CompositeController
  def sync = { status: {}, children: [] }
  def finalize = { status: {}, children: [], finalized: true }
  def customize = { relatedResources: [] }
end

class TestControllerWithEtags < Metatron::CompositeController
  def calculate_sync_etag = "abcd1234"
  def calculate_customize_etag = "efgh5678"
  def sync = { status: {}, children: [] }
  def finalize = { status: {}, children: [], finalized: true }
  def customize = { relatedResources: [] }
end

RSpec.describe Metatron::CompositeController do
  include Rack::Test::Methods

  context "when ETag support is NOT enabled" do
    let(:app) { Rack::Lint.new(TestController) }

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
      expect(last_response.headers.key?("etag")).to be(false)
    end

    it "returns a 200 for standard sync requests" do
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

    it "provides the expected data for standard sync requests" do
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

    it "returns a 200 OK for finalize requests" do
      post(
        "/finalize",
        { finalizing: true }.to_json,
        {
          "HTTP_ACCEPT" => "application/json",
          "Content-Type" => "application/json"
        }
      )
      expect(last_response.status).to eq(200)
    end

    it "returns the expected data for finalize requests" do
      post(
        "/finalize",
        { finalizing: true }.to_json,
        {
          "HTTP_ACCEPT" => "application/json",
          "Content-Type" => "application/json"
        }
      )
      expect(last_response.body).to eq({ status: {}, children: [], finalized: true }.to_json)
    end

    it "returns a 200 OK for initial customize requests" do
      post(
        "/customize",
        {},
        {
          "HTTP_ACCEPT" => "application/json",
          "Content-Type" => "application/json"
        }
      )
      expect(last_response.status).to eq(200)
    end

    it "returns the expected data for initial customize requests" do
      post(
        "/customize",
        {},
        {
          "HTTP_ACCEPT" => "application/json",
          "Content-Type" => "application/json"
        }
      )
      expect(last_response.body).to eq({ relatedResources: [] }.to_json)
    end

    it "does not provide an ETag header for initial customize requests" do
      post(
        "/customize",
        {},
        {
          "HTTP_ACCEPT" => "application/json",
          "Content-Type" => "application/json"
        }
      )
      expect(last_response.headers.key?("etag")).to be(false)
    end

    it "returns a 200 for standard customize requests" do
      post(
        "/customize",
        {},
        {
          "HTTP_ACCEPT" => "application/json",
          "HTTP_IF_NONE_MATCH" => "\"efgh5678\"", # This should be ignored
          "CONTENT_TYPE" => "application/json"
        }
      )
      expect(last_response.status).to eq(200)
    end

    it "provides the expected data for standard customize requests" do
      post(
        "/customize",
        {},
        {
          "HTTP_ACCEPT" => "application/json",
          "HTTP_IF_NONE_MATCH" => "\"efgh5678\"", # This should be ignored
          "CONTENT_TYPE" => "application/json"
        }
      )
      expect(last_response.body).to eq({ relatedResources: [] }.to_json)
    end
  end

  context "when ETag support is enabled" do
    let(:app) { Rack::Lint.new(TestControllerWithEtags) }

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
      expect(last_response.headers["etag"]).to eq("\"abcd1234\"")
    end

    it "returns a 412 for standard sync requests with ETag headers" do
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

    it "does not provide a body for standard sync requests with ETag headers" do
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

    it "returns a 200 OK for initial customize requests" do
      post(
        "/customize",
        {},
        {
          "HTTP_ACCEPT" => "application/json",
          "Content-Type" => "application/json"
        }
      )
      expect(last_response.status).to eq(200)
    end

    it "returns the expected data for initial customize requests" do
      post(
        "/customize",
        {},
        {
          "HTTP_ACCEPT" => "application/json",
          "Content-Type" => "application/json"
        }
      )
      expect(last_response.body).to eq({ relatedResources: [] }.to_json)
    end

    it "returns the expected ETag header for initial customize requests" do
      post(
        "/customize",
        {},
        {
          "HTTP_ACCEPT" => "application/json",
          "Content-Type" => "application/json"
        }
      )
      expect(last_response.headers["etag"]).to eq("\"efgh5678\"")
    end

    it "returns a 412 for standard customize requests with ETag headers" do
      post(
        "/customize",
        {},
        {
          "HTTP_ACCEPT" => "application/json",
          "HTTP_IF_NONE_MATCH" => "\"efgh5678\"",
          "CONTENT_TYPE" => "application/json"
        }
      )
      expect(last_response.status).to eq(412)
    end

    it "does not provide a body for standard customize requests with ETag headers" do
      post(
        "/customize",
        {},
        {
          "HTTP_ACCEPT" => "application/json",
          "HTTP_IF_NONE_MATCH" => "\"efgh5678\"",
          "CONTENT_TYPE" => "application/json"
        }
      )
      expect(last_response.body).to be_empty
    end
  end
end
