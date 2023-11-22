# frozen_string_literal: true

module Metatron
  module Templates
    # Template for basic Ingress k8s resource
    class Ingress < Template
      include Concerns::Namespaced

      attr_accessor :ingress_class, :additional_labels, :additional_annotations, :rules, :tls,
                    :cert_manager_cluster_issuer, :cert_manager_issuer, :cert_manager_challenge_type

      def initialize(name, ingress_class = "nginx")
        super(name)
        @ingress_class = ingress_class
        @api_version = "networking.k8s.io/v1"
        @additional_labels = {}
        @additional_annotations = {}
      end

      # Supports one of (they are all equivalent):
      #   { host: "foo.bar", service: { name: "some_service", port: "some_port" } }
      #   { "foo.bar" => { "some_service" => "some_port" } }
      #   {
      #     host: "foo.bar",
      #     paths: [{ path: "/", service: { name: "some_service", port: "some_port" } }]
      #   }
      def add_rule(rule)
        @rules ||= []
        @rules << (rule.key?(:host) ? complex_rule(rule) : simple_rule(rule))
      end

      # Supports an array of hostnames to provide TLS for via some secret
      # If the secret name isn't provide, its name will be derived from the first hostname
      def add_tls(*tls, secret: nil)
        @tls ||= []
        @tls << {
          hosts: tls.map(&:downcase),
          secretName: secret || secret_name_from_hostname(tls.first)
        }
      end

      def cert_manager_annotations
        cert_manager = {}
        if cert_manager_issuer
          cert_manager[:"cert-manager.io/issuer"] = cert_manager_issuer
        elsif cert_manager_cluster_issuer
          cert_manager[:"cert-manager.io/cluster-issuer"] = cert_manager_cluster_issuer
        end
        unless cert_manager.empty?
          cert_manager[:"cert-manager.io/acme-challenge-type"] =
            cert_manager_challenge_type || "http01"
        end

        {}.merge(cert_manager)
      end

      def formatted_annotations
        ingress_annotations = { "kubernetes.io/ingress.class": ingress_class }
        {
          annotations: ingress_annotations
            .merge(additional_annotations)
            .merge(cert_manager_annotations)
        }
      end

      def formatted_rules
        (rules || []).empty? ? {} : { rules: }
      end

      def formatted_tls
        (tls || []).empty? ? {} : { tls: }
      end

      def render
        {
          apiVersion:,
          kind:,
          metadata: {
            name:,
            labels: base_labels.merge(additional_labels)
          }.merge(formatted_annotations).merge(formatted_namespace),
          spec: formatted_rules.merge(formatted_tls)
        }
      end

      def secret_name_from_hostname(hostname)
        "#{hostname.downcase.gsub(".", "-")}-tls"
      end

      private

      # rubocop:disable Metrics/MethodLength
      def complex_rule(rule)
        formatted_rule = {}
        formatted_rule[:host] = rule[:host]
        paths = if rule.key?(:paths)
                  rule[:paths].map do |path|
                    {
                      pathType: "Prefix",
                      path: path[:path],
                      backend: {
                        service: {
                          name: path.dig(:service, :name),
                          port: { name: path.dig(:service, :port) }
                        }
                      }
                    }
                  end
                else
                  [
                    {
                      pathType: "Prefix",
                      path: "/",
                      backend: {
                        service: {
                          name: rule.dig(:service, :name),
                          port: { name: rule.dig(:service, :port) }
                        }
                      }
                    }
                  ]
                end
        formatted_rule[:http] = { paths: }
        formatted_rule
      end
      # rubocop:enable Metrics/MethodLength

      def simple_rule(rule)
        formatted_rule = {}
        formatted_rule[:host] = rule.keys.first.to_s
        service_name, service_port = rule.values.first.to_a.first
        formatted_rule[:http] = {
          paths: [
            pathType: "Prefix",
            path: "/",
            backend: {
              service: {
                name: service_name.to_s,
                port: { name: service_port }
              }
            }
          ]
        }
        formatted_rule
      end
    end
  end
end
