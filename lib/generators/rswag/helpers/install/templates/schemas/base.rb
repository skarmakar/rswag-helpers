# frozen_string_literal: true

module Schemas
  class Base < Rswag::Helpers::Schema
  end
end

Dir.children(Rails.root.join('spec', 'schemas')).each { |file_name| require_relative file_name }
