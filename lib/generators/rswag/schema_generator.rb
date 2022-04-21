# frozen_string_literal: true

require 'rails/generators'

module Rswag
  class SchemaGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('schema_templates', __dir__)

    def create_schema
      schema_dir_path = 'spec/schemas'
      generate 'rswag:helpers:install' unless File.file?("#{schema_dir_path}/base.rb")
      template 'schema.erb', "spec/schemas/#{class_name.underscore}.rb"
    end
  end
end
