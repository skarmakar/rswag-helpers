# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :have_keys do |*expected, within: nil|
  match do |actual|
    if actual.is_a?(Array)
      actual.each { |obj| (within ? obj[within.to_s] : obj).keys.sort == expected.sort }
    else
      (within ? actual[within.to_s] : actual).keys.sort == expected.sort
    end
  end
end

RSpec::Matchers.define :have_error do |message|
  match do |response|
    error_detail_array(response).include?(message)
  end
end

RSpec::Matchers.define :be_unauthorized do
  match do |response|
    error_detail_array(response).include?('Nil JSON web token')
  end
end

RSpec::Matchers.define :be_not_found do
  match do |response|
    error_detail_array(response).include?('Not found')
  end
end

RSpec::Matchers.define :have_all_the_records do |arel|
  match do |response|
    response_body = JSON.parse(response.body)
    records_count = arel.count
    response_body['meta']['count'] == records_count && response_body['data'].length == records_count
  end
end

RSpec::Matchers.define :have_ids do |ids_array|
  match do |hash_array|
    hash_array.collect { |h| h['id'] }.sort == (ids_array.is_a?(Array) ? ids_array : [ids_array]).sort
  end
end

RSpec::Matchers.define :have_id do |id|
  match do |hash|
    hash['id'] == id
  end
end

RSpec::Matchers.define :have_meta do |key, val|
  match do |response|
    JSON.parse(response.body)['meta'][key.to_s] == val
  end
end

# helper methods
def error_detail_array(response)
  JSON.parse(response.body)['errors'].collect { |h| h['detail'] }
end
