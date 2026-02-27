# frozen_string_literal: true

module Metatron
  module Templates
    class Gateway
      # Internal model for a Gateway listener
      class Listener
        attr_accessor :name, :port, :protocol, :hostname, :tls, :allowed_routes

        def initialize(name, port:, protocol:, hostname: nil, tls: nil, allowed_routes: nil)
          @name = name
          @port = port
          @protocol = protocol
          @hostname = hostname
          @tls = tls
          @allowed_routes = allowed_routes
        end

        def render
          { name:, port:, protocol: }
            .merge(hostname ? { hostname: } : {})
            .merge(tls ? { tls: } : {})
            .merge(allowed_routes ? { allowedRoutes: allowed_routes } : {})
        end
      end
    end
  end
end
