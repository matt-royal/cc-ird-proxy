require 'sinatra'
require 'net/http'
require 'json'

REAL_CC = 'http://api.10.244.0.34.xip.io'

get '*' do
  path = params[:splat].first
  log "Received request for #{path}"
  if ir_depth == 0
    res = get_url(REAL_CC, build_path(path, params), env["HTTP_AUTHORIZATION"])
  else
    base_json = JSON.parse(get_url(REAL_CC, path, env["HTTP_AUTHORIZATION"]))
    res = expand(base_json, ir_depth)
  end
  body JSON.pretty_generate(res)
end

def get_url(host, path, token)
  uri = URI("#{host}#{path}")
  log ">> Requesting #{uri}"
  req = Net::HTTP::Get.new(uri.request_uri)
  req['Authorization'] = token
  res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end
  res.body
end

def expand(base_json, depth)
  return nil if base_json['code'] # error case
  return base_json if depth == 0 # leaf node

  if base_json['resources']
    base_json['resources'] = base_json['resources'].map do |resource|
      expand_resource(resource, depth - 1)
    end
    base_json
  else
    expand_resource(base_json, depth - 1)
  end
end

def expand_resource(base_json, depth)
  log "base_json = #{base_json}"
  has_many_relationships = base_json.fetch('entity').keys.grep(/s_url/).map {|s| s.gsub(/_url$/, '')}
  has_one_relationships = base_json.fetch('entity').keys.grep(/[^s]_url/).map {|s| s.gsub(/_url$/, '')}
  has_many_relationships.each do |relationship|
    base_json = expand_has_many_relationship(base_json, relationship, depth) || []
  end
  has_one_relationships.each do |relationship|
    base_json = expand_has_one_relationship(base_json, relationship, depth)
  end
  base_json
end

def expand_has_one_relationship(json, relationship, depth)
  path_for_relationship = json.fetch('entity').fetch("#{relationship}_url")
  relationship_json = JSON.parse(get_url(REAL_CC, path_for_relationship, env["HTTP_AUTHORIZATION"]))
  json['entity'][relationship] = expand(relationship_json, depth)
  json
end

def expand_has_many_relationship(json, relationship, depth)
  path_for_relationship = json.fetch('entity').fetch("#{relationship}_url")
  relationship_json = JSON.parse(get_url(REAL_CC, path_for_relationship, env["HTTP_AUTHORIZATION"]))
  json['entity'][relationship] = expand(relationship_json, depth).fetch('resources')
  json
end

def log(msg)
  puts "="*80
  puts msg
  puts "="*80
end

def build_path(path, params)
  raise 'No path' unless path
  "#{path}?inline-relations-depth=#{ir_depth}".tap do |p|
    log "path = #{p.inspect}"
  end
end

def ir_depth
  params['inline-relations-depth'].to_i
end
