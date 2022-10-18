# frozen_string_literal: true

module Metatron
  # Used for "normal" sync requests
  class SyncController < Controller
    options "/" do
      headers "Access-Control-Allow-Methods" => ["POST"]
      halt 200
    end

    post "/" do
      halt(sync.to_json)
    end
  end
end
