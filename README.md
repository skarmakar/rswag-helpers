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

  1. create a folder `spec/schemas` and also create a file `spec/schemas/base` inside that folder
  2. Modify the `spec/swagger_helper.rb` file to include the custom rspec matchers and rswag helpers
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
                name: { type: :string, default: 'Cheese Bacon sandwich' },
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
