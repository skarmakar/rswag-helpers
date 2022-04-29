# frozen_string_literal: true

# Support the array of objects query params for markets/new action, points param
# The release 2.5.1 yet not support deepObject, it's supported in the master branch
# Once a new version is released - we can make a change to handle thigs better

# require the class from rswag gem
require 'rswag/specs/request_factory'

Rswag::Specs::RequestFactory.class_eval do
  private

  # https://github.com/rswag/rswag/blob/6f4541128900ccae79b26d4f77810866769fdf89/rswag-specs/lib/rswag/specs/request_factory.rb#L123
  def build_query_string_part(param, value)
    name = param[:name]
    type = param[:type] || param.dig(:schema, :type)

    # OAS 3: https://swagger.io/docs/specification/serialization/
    if Rswag::Specs.config.swagger_docs.values.first[:openapi].start_with?('3') && param[:schema]
      style = param[:style]&.to_sym || :form
      explode = param[:explode].nil? ? true : param[:explode]

      case param[:schema][:type].to_sym
      when :object
        case style
        when :deepObject
          return { name => value }.to_query
        when :form
          if explode
            return value.to_query
          else
            return "#{CGI.escape(name.to_s)}=" + value.to_a.flatten.map{|v| CGI.escape(v.to_s) }.join(',')
          end
        end
      when :array
        case explode
        when true
          return value.to_a.flatten.map{|v| "#{CGI.escape(name.to_s)}=#{CGI.escape(v.to_s)}"}.join('&')
        else
          separator = case style
                      when :form then ','
                      when :spaceDelimited then '%20'
                      when :pipeDelimited then '|'
                      end
          return "#{CGI.escape(name.to_s)}=" + value.to_a.flatten.map{|v| CGI.escape(v.to_s) }.join(separator) 
        end
      else
        return "#{name}=#{value}"
      end
    end

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
