# frozen_string_literal: true

require "json" unless defined? JSON # allow for JSON to be loaded elsewhere

module Metatron
  # Helpers for RFC 9457 "Problem Details for HTTP APIs" responses.
  #
  # Problem documents give clients a machine-readable error body without
  # leaking internals (backtraces, environment, gem versions). They are used
  # by the shipped middleware and by the controller's exception boundary.
  module Problem
    # Media type used for problem documents.
    CONTENT_TYPE = "application/problem+json"

    # Stable problem type identifiers. These are identifiers only; they are
    # not required to resolve to a human-readable page.
    TYPES = {
      401 => "urn:metatron:problem:unauthorized",
      413 => "urn:metatron:problem:payload-too-large",
      500 => "urn:metatron:problem:internal-server-error"
    }.freeze

    class << self
      # Build a Rack response triple carrying a problem document.
      #
      # @param status [Integer] the HTTP status code
      # @param title [String] a short, human-readable summary of the problem
      # @param detail [String, nil] a human-readable explanation of this occurrence
      # @param type [String, nil] overrides the default problem type for the status
      # @param headers [Hash] additional response headers
      # @return [Array] a Rack response
      def response(status:, title:, detail: nil, type: nil, headers: {})
        body = document(status: status, title: title, detail: detail, type: type)
        [status, { "content-type" => CONTENT_TYPE }.merge(headers), [body]]
      end

      # Build a problem document.
      #
      # @return [String] the serialized problem document
      def document(status:, title:, detail: nil, type: nil)
        problem = { type: type || TYPES.fetch(status, "about:blank"), title: title, status: status }
        problem[:detail] = detail unless detail.nil?
        problem.to_json
      end
    end
  end
end
