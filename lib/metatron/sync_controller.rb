# frozen_string_literal: true

module Metatron
  # Used for "normal" sync requests
  class SyncController < Controller
    options "/" do
      headers "Access-Control-Allow-Methods" => ["POST"]
      halt 200
    end

    post "/" do
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
