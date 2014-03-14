require 'sinatra'
require 'net/http'
require 'json'

get '*' do
  @real_cc = env.fetch('HTTP_CC')
  path = params[:splat].first
  log "Received request for #{path}"
  base_json = JSON.parse(get_url(@real_cc, path, env["HTTP_AUTHORIZATION"]))
  relationships_to_omit = [resource_name(path), "#{resource_name(path)}s", "events", "app_events", "dashboard", "info"]
  res = expand(base_json, ir_depth, relationships_to_omit)
  body JSON.pretty_generate(res)
end

def get_url(host, path, token)
  log ">> Requesting #{host}#{path}"
  uri = URI("#{host}#{path}")
  req = Net::HTTP::Get.new(uri.request_uri)
  req['Authorization'] = token
  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
    http.request(req)
  end
  res.body
end

def expand(base_json, depth, relationships_to_omit)
  return nil if base_json['code'] # error case
  return base_json if depth == 0 # leaf node

  if base_json['resources']
    base_json['resources'] = base_json['resources'].map do |resource|
      expand_resource(resource, depth - 1, relationships_to_omit)
    end
    base_json
  else
    expand_resource(base_json, depth - 1, relationships_to_omit)
  end
end

def expand_resource(base_json, depth, relationships_to_omit)
  log "base_json = #{base_json}"
  has_many_relationships = base_json.fetch('entity').keys.grep(/s_url/).map {|s| s.gsub(/_url$/, '')}
  has_one_relationships = base_json.fetch('entity').keys.grep(/[^s]_url/).map {|s| s.gsub(/_url$/, '')}
  has_many_relationships.each do |relationship|
    next if relationships_to_omit.include?(relationship)
    base_json = expand_has_many_relationship(base_json, relationship, depth, relationships_to_omit) || []
  end
  has_one_relationships.each do |relationship|
    next if relationships_to_omit.include?(relationship)
    base_json = expand_has_one_relationship(base_json, relationship, depth, relationships_to_omit)
  end
  base_json
end

def expand_has_one_relationship(json, relationship, depth, relationships_to_omit)
  path_for_relationship = json.fetch('entity').fetch("#{relationship}_url")
  relationship_json = JSON.parse(get_url(@real_cc, path_for_relationship, env["HTTP_AUTHORIZATION"]))
  json['entity'][relationship] = expand(relationship_json, depth, relationships_to_omit)
  json
end

def expand_has_many_relationship(json, relationship, depth, relationships_to_omit)
  path_for_relationship = json.fetch('entity').fetch("#{relationship}_url")
  relationship_json = JSON.parse(get_url(@real_cc, path_for_relationship, env["HTTP_AUTHORIZATION"]))
  json['entity'][relationship] = expand(relationship_json, depth, relationships_to_omit).fetch('resources')
  json
end

def resource_name(path)
  components = path.split('/')
  resource = components.last.match(/\d/) ? components[-2] : components.last
  resource.gsub(/s$/, '') # de-pluralize
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
