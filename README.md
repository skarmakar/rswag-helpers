# Rswag::Helpers

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/rswag/helpers`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

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

This gem adds some helper methods to make rswag specs DRY and more readable. Install the gem:

    $ rails g rswag:helpers:install

This will 

  1. create a folder `spec/schemas` and also create a file `spec/schemas/base` inside that folder
  2. Modify the `spec/swagger_helper.rb` file to include the custom rspec matchers and rswag helpers
  3. Provide predefined ways to define the security schemes like :bearer_jwt, :basic_http, :api_key
  4. Also provides options to add additional security schemes, example:


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

### spec/schemas folder

Keeping all the schemas in the `spec/swagger_helper.rb` can make the file very long and tough to maintain. It would be better
if we can keep the schemas in multiple files. This gem does the setup for that, and creates the `spec/schemas` folder for that purpose. Now other schema files can reside inside that, and can be auto loaded to be used from `spec/swagger_helper.rb`

Example schema:

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

And use it:

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


