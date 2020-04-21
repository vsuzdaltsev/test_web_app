#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'sinatra/base'
require 'sinatra/streaming'

require_relative File.expand_path('../conf', __dir__)

# Api class
class RestApi < Sinatra::Base
  helpers Sinatra::Streaming

  BASE_URL           = TestAppConf::DEFAULTS[:api_url_base_v1]
  VALID_HTTP_METHODS = TestAppConf::DEFAULTS[:valid_http_methods]
  VERSION            = TestAppConf::DEFAULTS[:version].call

  def self.create_rest_api
    version

    create_default_route_methods(VALID_HTTP_METHODS).each do |http_method|
      send("create_#{http_method}_default_route")
    end
  end

  def self.version
    get "#{BASE_URL}/version" do
      stream do |out|
        content_type :json
        out.puts(File.read(VERSION).chomp.to_json)
      end
    end
  end

  def self.create_default_route_methods(http_methods)
    http_methods.each do |method|
      define_singleton_method("create_#{method}_default_route") do
        send(method, '/*') do
          stream do |out|
            content_type :json
            out.puts({ "#{method}": 'default_route' }.to_json)
          end
        end
      end
    end
  end
end
