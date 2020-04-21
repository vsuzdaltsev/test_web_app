#!/usr/bin/env ruby
# frozen_string_literal: true

class TestAppConf
  DEFAULTS = {
    valid_http_methods: %w[
      delete
      get
      patch
      post
      put
    ],
    api_url_base_v1: '/api/v1',
    reporter_ecr_repo: 'reporter',
    keep_images: 2,
    version: -> { File.expand_path('./version.txt', __dir__) }
  }.freeze
  LOG_LEVEL = -> { Logger::DEBUG }.freeze
  DOCKER = {
    env_file: '.env'
  }.freeze
  UNICORN = lambda do
    {
      working_dir: '/opt/app',
      ruby_ver: File.readlines('./Gemfile').grep(/ruby /).join.split[1].delete('\''),
      host: '0.0.0.0',
      port: '4570',
      timeout: '5',
      workers: '2',
      container_name: 'test-app'
    }
  end
end
