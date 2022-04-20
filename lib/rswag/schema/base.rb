module Rswag
  module Schema
    class Base
      class << self
        # default, override in subclasses if necessary
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
