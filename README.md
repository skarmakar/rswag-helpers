# Rswag::Helpers

This gem adds some helper methods, custom rspec matchers and predefined security schemes to make [Rswag](https://github.com/rswag/rswag) specs DRY and more readable.

  1. Create a helper method to remove redundant [Enable auto generation examples from responses](https://github.com/rswag/rswag#enable-auto-generation-examples-from-responses). So this code

  ```ruby
  get('list posts') do
    response(200, 'successful') do

      after do |example|
        example.metadata[:response][:content] = {
          'application/json' => {
            example: JSON.parse(response.body, symbolize_names: true)
          }
        }
      end
      run_test!
    end
  end
  ```

  can be replaced by

  ```ruby
  get('list posts') do
    response(200, 'successful') do
      run_test_and_generate_example!
    end
  end
  ```

  2. Provides ability to define schemas in separate files - explained below
  3. Adds a bunch of custom rspec matchers for better readability
  4. Provides ability to use some predefined security schemes
  5. Provides a helper method `define_tags` to replace the repetitive tag definition with `security scheme`, `consumes` and `produces`

  ```ruby
  tags 'Post'
  security [bearer_auth: []]
  consumes 'application/json'
  produces 'application/json'
  ```

  can be replaced by

  ```ruby
  define_tags 'Posts'

  # more customization
  define_tags 'Posts', consumes: 'multipart/form-data'
  ```

  6. Provides a helper method `schema_ref` which can take a string argument to replace declarative schema reference

  ```ruby
  schema '$ref' => '#/components/schemas/Something'
  # can be replace by
  schema_ref 'Something'
  
  schema anyOf: [{ '$ref' => '#/components/schemas/Something' }, { '$ref' => '#/components/schemas/SomethingElse' }]
  # can be replaced by
  schema_ref anyOf: ['Something', 'SomethingElse']

  schema oneOf: [{ '$ref' => '#/components/schemas/Something' }, { '$ref' => '#/components/schemas/SomethingElse' }]
  # can be replaced by
  schema_ref oneOf: ['Something', 'SomethingElse']

  schema allOf: [{ '$ref' => '#/components/schemas/Something' }, { '$ref' => '#/components/schemas/SomethingElse' }]
  # can be replaced by
  schema_ref allOf: ['Something', 'SomethingElse']

  ```

  7. Provides another helper method `schema_option` to make the schema declaration for a request short (trivial, but still less code)

  ```ruby
  parameter name: :payload, in: :body, schema: { '$ref' => '#/components/schemas/Something' }
  # can be replaced by
  parameter name: :payload, in: :body, schema: schema_option('Something')
  
  ```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rswag-helpers'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rswag-helpers

## Usage

Install the gem:

    $ rails g rswag:helpers:install

This will 

  1. Create a folder `spec/schemas` and also create a file `spec/schemas/base` inside that folder
  2. Modify the `spec/swagger_helper.rb` file to include the custom rspec matchers and rswag helpers

  ```ruby
  # spec/swagger_helper.rb

  # loads all the defined schema files
  require_relative 'schemas/base'  

  # Change to :api_key/:http_basic in case those are being used
  # Can also provide multiple defaults like: [:bearer_jwt, :api_key]
  # Can provide custom security scheme like: Rswag::Helpers::SecurityScheme.additional = { accept: {...}}
  Rswag::Helpers::SecurityScheme.defaults = :bearer_jwt

  ```

  3. Provide predefined ways to define the security schemes like :bearer_jwt, :basic_http, :api_key
  4. Also provides options to add additional security schemes, example:

  ```ruby
  # spec/swagger_helper.rb

  Rswag::Helpers::SecurityScheme.defaults = :bearer_jwt
  Rswag::Helpers::SecurityScheme.additional = {
    accept: {
      description: "Use application/[custom]; version=1",
      type: :apiKey,
      name: 'Accept',
      in: :header
    }
  }
  ```

### spec/schemas folder

Keeping all the schemas in the `spec/swagger_helper.rb` can make the file very long and tough to maintain. It would be better
if we can keep the schemas in multiple files. This gem does the setup for that, and creates the `spec/schemas` folder for that purpose. Now other schema files can reside inside that, and can be auto loaded to be used from `spec/swagger_helper.rb`

Example schema:

  ```ruby
  # spec/schemas/post.rb

  class Schemas::Post < Schemas::Base
    class << self
      def schema
        @schema ||= {
          type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                title: { type: :string, default: 'Cheese Bacon sandwich' },
                description: { type: :test, default: 'A great breakfast recipe!' },
              }
            }
          }
        }
      end
    end
  end
  ```

And use it:

  ```ruby
  # spec/swagger_helper.rb
  
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.3',
      info: {
        title: 'API Docs',
        version: 'v1'
      },
      components: {
        securitySchemes: Rswag::Helpers::SecurityScheme.get,
        schemas: {
          Post: Schemas::Post.schema,
        },
        security: Rswag::Helpers::SecurityScheme.security,
        paths: {},
        servers: []
      }
    }
  }
  ```

  These schema files are a subclass of `Schemas::Base` class for the purpose of loading a single file from the `spec/swagger_helper.rb`. Also, `Schemas::Base` is a subclass of `Rswag::Helpers::Schema` class present in the gem, which provides handy `request_body` method to extract the default values from the schema and construct the 
  request body of POST/PUT requests. For an example:

  ```ruby
  post('create post') do
    define_tags 'Post'

    parameter name: :body, in: :body, schema: { '$ref' => '#/components/schemas/Post' }, required: true
    # request_body method is present in the gem
    let(:post_request_body) { Schemas::Post.request_body.deep_dup }

    response(200, 'successful') do
      let(:body) { post_request_body }

      run_test_and_generate_example! do |response|
        response_body = parsed_response(response, key: nil)
        expect(response_body['data']['attributes']).to have_keys('title', 'description')
      end
    end
  end
  ```

  ### Generate a schema

      $ rails g rswag:schema ResourceName

  Generates `spec/schemas/resource_name.rb` with the code:

  ```ruby
  module Schemas
    class ResourceName < Base
      class << self
        def schema
          @schema ||= {
            type: :object,
            properties: {
            }
          }
        end
      end
    end
  end
  ```
