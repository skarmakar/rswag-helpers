# frozen_string_literal: true

module Rswag
  module Helpers
    class SecurityScheme
      class << self
        attr_accessor :defaults, :additional

        def get
          schemes = {}

          if defaults
            (defaults.is_a?(Array) ? defaults : [defaults]).each { |h| schemes.merge!(send(h)) }
          end

          if additional.present?
            (additional.is_a?(Array) ? additional : [additional]).each { |h| schemes.merge!(h) }
          end

          schemes
        end

        def security
          get.keys.each_with_object([]).to_h
        end

        private

        def bearer_jwt
          {
            bearer: {
              type: :http,
              scheme: :bearer,
              bearerFormat: :JWT,
              description: 'Bearer [JWT token]'
            }
          }
        end

        def basic_auth
          {
            basic_auth: {
              type: :http,
              scheme: :basic
            }
          }
        end

        def api_key
          {
            api_key: {
              type: :apiKey,
              name: 'api_key',
              in: :query
            }
          }
        end
      end
    end
  end
end
