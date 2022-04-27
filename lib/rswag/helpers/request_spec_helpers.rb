# frozen_string_literal: true

# This file defines some general purpose methods, being loaded from spec/swagger_helper.rb
# Added a separate file to keep spec/swagger_helper.rb slim so that upgrades are painless

def parsed_response(response, key: 'data')
  key ? JSON.parse(response.body)[key] : JSON.parse(response.body)
end

def parsed_response_errors(response)
  parsed_response(response, key: 'errors')
end

# `SWAGGER_DRY_RUN=0 RAILS_ENV=test rails rswag` should run specs and auto generate examples
def run_test_and_generate_example!(&block)
  after do |example|
    if response&.body&.present?
      example.metadata[:response][:content] = {
        'application/json' => {
          example: JSON.parse(response.body, symbolize_names: true)
        }
      }
    end
  end

  run_test!(&block)
end

def sample_uuid
  @sample_uuid ||= '52c8e67a-0589-4d4b-8732-041e7b9b44b4'
end

# wrap the repeatative 4 lines in a single method for easier maintenance
# usage: define_tag 'Airports'
# usage: define_tag 'Blah', consumes: 'multipart/form-data'
def define_tags(name, consumes: 'application/json', produces: 'application/json')
  tags name
  security [Rswag::Helpers::SecurityScheme.security]
  consumes consumes
  produces produces
end

# wrap the verbose schema definition in a method, as by convention
# schemas are expected to defined within /components/schemas in swagger_helper.rb 
def schema_ref(name)
  schema '$ref': "#/components/schemas/#{name}"
end

# wrap the verbose schema option in a method
def schema_option(name)
  { '$ref' => "#/components/schemas/#{name}" }
end
