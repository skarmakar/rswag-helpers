# frozen_string_literal: true

module Rswag
  module Helpers
    class Schema
      class << self
        def request_body(source_hash = nil)
          source_hash ||= schema
    
          if source_hash.keys.include?(:properties)
            properties = source_hash[:properties]
      
            if properties.keys.length == 1
              # has nested key
              nested_key = properties.keys.first
              { nested_key => request_body(properties[nested_key]) }
            else
              extract_defaults(properties)
            end
          else
            extract_defaults(source_hash)
          end
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
