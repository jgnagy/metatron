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
      if (provided_etag = calculate_etag)
        etag provided_etag
      end

      data = sync
      data[:children] = data[:children]&.map { |c| c.respond_to?(:render) ? c.render : c }
      halt(data.to_json)
    end

    def calculate_etag = nil
    def sync = raise NotImplementedError
  end
end
