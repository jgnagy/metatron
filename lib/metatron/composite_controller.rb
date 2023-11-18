# frozen_string_literal: true

module Metatron
  # Implementes a Metacontroller CompositeController
  # @see https://metacontroller.github.io/metacontroller/api/compositecontroller.html
  class CompositeController < Controller
    options "/sync" do
      headers "Access-Control-Allow-Methods" => ["POST"]
      halt 200
    end

    post "/sync" do
      if (provided_etag = calculate_sync_etag)
        etag provided_etag
      end

      data = sync
      data[:children] = data[:children]&.map { |c| c.respond_to?(:render) ? c.render : c }
      halt(data.to_json)
    end

    options "/finalize" do
      headers "Access-Control-Allow-Methods" => ["POST"]
      halt 200
    end

    post "/finalize" do
      # finalize calls should be rare and unique enough that we don't need to worry about ETags

      data = finalize
      data[:children] = data[:children]&.map { |c| c.respond_to?(:render) ? c.render : c }
      halt(data.to_json)
    end

    options "/customize" do
      headers "Access-Control-Allow-Methods" => ["POST"]
      halt 200
    end

    post "/customize" do
      if (provided_etag = calculate_customize_etag)
        etag provided_etag
      end

      halt(customize.to_json)
    end

    def calculate_customize_etag = nil
    def calculate_sync_etag = nil
    def customize = raise NotImplementedError
    def finalize = raise NotImplementedError
    def sync = raise NotImplementedError
  end
end
