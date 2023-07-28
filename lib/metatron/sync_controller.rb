# frozen_string_literal: true

module Metatron
  # Used for "normal" sync requests
  class SyncController < Controller
    options "/" do
      headers "Access-Control-Allow-Methods" => ["POST"]
      halt 200
    end

    post "/" do
      data = sync
      data[:children] = data[:children]&.map { |c| c.respond_to?(:render) ? c.render : c }
      halt(data.to_json)
    end
  end
end
