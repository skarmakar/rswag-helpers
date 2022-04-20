# frozen_string_literal: true

require 'rails/generators'
require 'fileutils'

module Rswag
  module Helpers
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def create_schemas_dir
        FileUtils.mkdir_p 'spec/schemas'
      end

      def add_base_schema
        template('schemas/base.rb', 'spec/schemas/base.rb')
      end

      def require_schema_from_swagger_helper_file
        inject_into_file 'spec/swagger_helper.rb', after: "require 'rails_helper'" do
          <<~HEREDOC
            \n
            require_relative 'schemas/base'
            # Change to :api_key/:http_basic in case those are being used
            # Can also provide multiple defaults like: [:bearer_jwt, :api_key]
            # Can provide custom security scheme like: Rswag::Helpers::SecurityScheme.additional = { accept: {...}}
            Rswag::Helpers::SecurityScheme.defaults = :bearer_jwt

            # PLEASE MAKE THE CHANGE in the swagger_docs config below:
            # securitySchemes: Rswag::Helpers::SecurityScheme.get
            # security: Rswag::Helpers::SecurityScheme.security
          HEREDOC
        end
      end
    end
  end
end
