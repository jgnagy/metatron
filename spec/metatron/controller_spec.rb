# frozen_string_literal: true

require "rack"
require "rack/test"

class ExplodingTestController < Metatron::CompositeController
  def sync = raise(ArgumentError, "boom: sensitive-secret-value")
  def customize = { relatedResources: [] }
  def finalize = { status: {}, children: [] }
end

class UnimplementedTestController < Metatron::CompositeController; end

class NilParamsTestController < Metatron::CompositeController
  def sync = { status: { name: params["parent"] }, children: [] }
  def customize = { relatedResources: [] }
  def finalize = { status: {}, children: [] }
end

RSpec.describe Metatron::Controller do
  include Rack::Test::Methods

  before do
    allow(Metatron.logger).to receive(:error)
  end

  context "when the controller raises" do
    let(:app) { Rack::Lint.new(ExplodingTestController) }

    it "returns a 500 status" do
      post "/sync", {}, { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(500)
    end

    it "returns a JSON problem document" do
      post "/sync", {}, { "CONTENT_TYPE" => "application/json" }
      expect(last_response.headers["content-type"]).to eq("application/problem+json")
    end

    it "describes the failure generically" do
      post "/sync", {}, { "CONTENT_TYPE" => "application/json" }
      expect(JSON.parse(last_response.body)).to include("status" => 500,
                                                        "title" => "Internal Server Error")
    end

    it "does not leak the exception message" do
      post "/sync", {}, { "CONTENT_TYPE" => "application/json" }
      expect(last_response.body).not_to include("sensitive-secret-value")
    end

    it "does not leak a backtrace" do
      post "/sync", {}, { "CONTENT_TYPE" => "application/json" }
      expect(last_response.body).not_to include("lib/metatron")
    end

    it "logs the exception class and message" do
      post "/sync", {}, { "CONTENT_TYPE" => "application/json" }
      expect(Metatron.logger).to have_received(:error).with(/ArgumentError.*boom/m)
    end

    it "logs the backtrace" do
      post "/sync", {}, { "CONTENT_TYPE" => "application/json" }
      expect(Metatron.logger).to have_received(:error).with(/controller\.rb/)
    end
  end

  context "when the controller does not implement the hook" do
    let(:app) { Rack::Lint.new(UnimplementedTestController) }

    it "returns a JSON 500 rather than crashing" do
      post "/sync", {}, { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(500)
    end

    it "returns a problem document" do
      post "/sync", {}, { "CONTENT_TYPE" => "application/json" }
      expect(last_response.headers["content-type"]).to eq("application/problem+json")
    end
  end

  context "when the request has no JSON body" do
    let(:app) { Rack::Lint.new(NilParamsTestController) }

    it "returns a JSON 500 rather than crashing" do
      post "/sync"
      expect(last_response.status).to eq(500)
    end
  end

  context "when the request body is not valid JSON" do
    let(:app) { Rack::Lint.new(NilParamsTestController) }

    it "returns a 400 status" do
      post "/sync", "{not json", { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(400)
    end

    it "explains that the request must be JSON" do
      post "/sync", "{not json", { "CONTENT_TYPE" => "application/json" }
      expect(JSON.parse(last_response.body)["error"]).to include("Request must be JSON")
    end
  end
end
