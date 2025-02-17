# frozen_string_literal: true

module Metatron
  # Implementes a Metacontroller CompositeController
  # @see https://metacontroller.github.io/metacontroller/api/compositecontroller.html
  class CompositeController < Controller
    def initialize(env)
      super
      @strategy = nil
    end

    def calculate_customize_etag = nil
    def calculate_sync_etag = nil
    def customize = raise NotImplementedError
    def finalize = raise NotImplementedError
    def sync = raise NotImplementedError

    STRATEGY = {
      "/customize" => { data: :customize, etag: :calculate_customize_etag },
      # finalize calls should be rare and unique enough that we don't need to worry about ETags
      "/finalize" => { data: :finalize },
      "/sync" => { data: :sync, etag: :calculate_sync_etag }
    }.freeze

    private

    def _call
      return access_control_allow_methods if request.options?
      return not_found unless request.post?

      @strategy = STRATEGY.fetch(request.path_info) { return not_found }

      headers = {}

      return Rack::Response[412, headers, []].to_a if etag_matches?(headers)

      Rack::Response[200, headers, processed_data].to_a
    end

    def access_control_allow_methods
      Rack::Response[200, { "access-control-allow-methods" => %w[POST] }, []].to_a
    end

    def not_found
      Rack::Response[404, { "x-cascade" => "pass" }, []].to_a
    end

    def etag_matches?(headers)
      return false unless (calculator = @strategy[:etag])
      return false unless (raw_etag = public_send(calculator))

      etag = +'"' << raw_etag << '"'
      headers["etag"] = etag

      (none_match = request.get_header("HTTP_IF_NONE_MATCH")) && none_match.include?(etag)
    end

    def processed_data
      data = public_send(@strategy[:data])

      if data[:children]
        data[:children] = data[:children].map { |c| c.respond_to?(:render) ? c.render : c }
      end

      data.to_json
    end
  end
end
