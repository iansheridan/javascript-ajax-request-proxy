require 'rubygems'
require 'sinatra'
require 'rest_client'
require 'restclient/components'
require 'logger'

RestClient.enable Rack::CommonLogger, $stdout
RestClient.log = Logger.new(STDOUT)

@@par = Hash.new
@@url = ''
@@auth = ''

configure do
  class << Sinatra::Base
    def options(path, opts={}, &block)
      route 'OPTIONS', path, opts, &block
    end
  end
  Sinatra::Delegator.delegate :options
end

before do
  puts request.env["HTTP_ACCESS_CONTROL_REQUEST_HEADERS"]
  response.headers["Access-Control-Allow-Origin"] = "*"
  response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = request.env["HTTP_ACCESS_CONTROL_REQUEST_HEADERS"]
  response.headers["Access-Control-Max-Age"] = "1728000"
  
  env.each { |key, value|
    if key.index('HTTP') == 0
      if key == 'HTTP_PROXY_URL'
        @@url = value
      end
      if key == 'HTTP_AUTHORIZATION'
        @@auth = value
      end
    end
  }
  params.each { |key, value|
    @@par[key] = value
  }
end

get '/' do
  RestClient.get(@@url, { :accept => :json, :authorization => @@auth }) {|response, request, result| halt response.code, response.headers, response.body}
end

post '/' do
  RestClient.post(@@url, params, :accept => :json, :authorization => @@auth) {|response, request, result| halt response.code, response.headers, response.body}
end

put '/' do
  RestClient.put(@@url, @@par) {|response, request, result| halt response.code, response.headers, response.body}
end

delete '/' do
  RestClient.delete(@@url, @@par) {|response, request, result| halt response.code, response.headers, response.body}
end

options '/' do
  halt 200
end