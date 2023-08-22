# frozen_string_literal: true

module Metatron
  # Used for "normal" sync requests
  class SyncController < Controller
    options "/" do
      headers "Access-Control-Allow-Methods" => ["POST"]
      halt 200
    end

    post "/" do
      # TODO: move this to Sinatra's `etag` helper when Metacontroller is RFC compliant
      if (provided_etag = calculate_etag) &&
         (match_header = request.env["HTTP_IF_NONE_MATCH"]) &&
         match_header.split(/,\s?/).include?("\"#{provided_etag}\"")
        halt 304
      end

      # If the etag is available, use it, otherwise proceed with the sync
      headers "ETag" => "\"#{provided_etag}\"" if provided_etag
      data = sync
      data[:children] = data[:children]&.map { |c| c.respond_to?(:render) ? c.render : c }
      halt(data.to_json)
    end

    def calculate_etag = nil
    def sync = raise NotImplementedError
  end
end
