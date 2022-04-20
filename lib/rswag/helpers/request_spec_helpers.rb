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

# Wrap the spec/swagger_helper.rb securitySchemes in a method
# So that the keys are manageable and can DRY the security options for request specs
def swagger_helper_security_schemes
  @swagger_helper_security_schemes ||= {
    Bearer: {
      type: :http,
      description: 'Bearer [JWT token]',
      scheme: :bearer,
      bearerFormat: :JWT
    },
    Accept: {
      description: "Custom Accept header. Please use: #{VND_ACCEPT_HEADER}",
      type: :apiKey,
      name: 'Accept',
      in: :header
    }
  }
end

# spec/swagger_helper.rb security options, generated from swagger_helper_security_schemes definition
# example: {:Bearer=>[], :Accept=>[]}
def swagger_helper_security
  @swagger_helper_security ||= swagger_helper_security_schemes.keys.each_with_object([]).to_h
end

# wrap the repeatative 4 lines in a single method for easier maintenance
# usage: define_tag 'Airports'
# usage: define_tag 'Blah', consumes: 'multipart/form-data'
def define_tags(name, consumes: 'application/json', produces: 'application/json')
  tags name
  security [swagger_helper_security]
  consumes consumes
  produces produces
end
