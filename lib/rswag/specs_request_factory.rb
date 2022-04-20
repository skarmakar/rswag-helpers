# frozen_string_literal: true

# Support the array of objects query params for markets/new action, points param
# The release 2.5.1 yet not support deepObject, it's supported in the master branch
# Once a new version is released - we can make a change to handle thigs better

# require the class from rswag gem
require 'rswag/specs/request_factory'

Rswag::Specs::RequestFactory.class_eval do
  private

  def build_query_string_part(param, value)
    name = param[:name]
    type = param[:type] || param.dig(:schema, :type)
    return "#{name}=#{value}" unless type&.to_sym == :array

    case param[:collectionFormat]
    when :ssv
      "#{name}=#{value.join(' ')}"
    when :tsv
      "#{name}=#{value.join('\t')}"
    when :pipes
      "#{name}=#{value.join('|')}"
    when :multi
      # support for array of objects - Santanu Karmakar
      if value.is_a?(Array)
        { name.to_s.sub('[]', '') => value }.to_query
      else
        value.map { |v| "#{name}=#{v}" }.join('&')
      end
    else
      "#{name}=#{value.join(',')}" # csv is default
    end
  end
end
