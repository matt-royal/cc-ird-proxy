#!/usr/bin/env ruby
require 'json'

json = JSON.parse(STDIN.read)

def order_hash_by_keys(hash)
  hash.keys.sort.each_with_object({}) do |key, result_hash|
    value = hash[key]
    result_hash[key] = if value.is_a?(Hash)
                         order_hash_by_keys(value)
                       elsif value.is_a?(Array) && value.first.is_a?(Hash)
                         value.map {|e| order_hash_by_keys(e) }.sort_by {|e| e.fetch('metadata').fetch('guid') }
                       else
                         value
                       end
  end
end

print JSON.pretty_generate(order_hash_by_keys(json))
