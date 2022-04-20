# frozen_string_literal: true

module Rswag
  module Helpers
    class Schema
      class << self
        def request_body
          @request_body ||= { data: extract_defaults(schema[:properties][:data][:properties]) }
        end

        def extract_defaults(hash)
          {}.tap do |h|
            hash.each do |k, v|
              h[k] = v[:default]
            end
          end
        end
      end
    end
  end
end
