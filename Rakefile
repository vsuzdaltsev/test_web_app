#!/usr/bin/env ruby

# frozen_string_literal: true

require 'mkmf'

require_relative File.expand_path('./src/conf', __dir__)

NECESSARY_SOFT = %w[ruby docker docker-compose gem].freeze

RUBY_VER          = TestAppConf::UNICORN.call[:ruby_ver]
APP_DIR           = TestAppConf::UNICORN.call[:working_dir]
UNICORN_CONTAINER = TestAppConf::UNICORN.call[:container_name]
UNICORN_HOST      = TestAppConf::UNICORN.call[:host]
UNICORN_PORT      = TestAppConf::UNICORN.call[:port]
UNICORN_TIMEOUT   = TestAppConf::UNICORN.call[:timeout]
UNICORN_WORKERS   = TestAppConf::UNICORN.call[:workers]
DOCKER_ENV_FILE   = TestAppConf::DOCKER[:env_file]

task :default do
  puts ">> Type 'rake --tasks' to list existent tasks"
end

namespace :version do
  task :generate do
    File.write(
      'version.txt',
      {
        project:    'git@github.com:vsuzdaltsev/test_web_app.git',
        built_at:   Time.now.utc,
        commit_sha: `git rev-parse HEAD`
      }.to_json
    )
  end
end

namespace :docker_compose do
  task :create_env_file do
    puts ">> Create env file #{DOCKER_ENV_FILE}"
    %W[
      APP_DIR=#{APP_DIR}
      RUBY_VER=#{RUBY_VER}
      UNICORN_PORT=#{UNICORN_PORT}
      UNICORN_HOST=#{UNICORN_HOST}
      UNICORN_TIMEOUT=#{UNICORN_TIMEOUT}
      UNICORN_WORKERS=#{UNICORN_WORKERS}
      UNICORN_CONTAINER=#{UNICORN_CONTAINER}
    ].join("\n").tap { |vars| IO.write(DOCKER_ENV_FILE, vars) }
  end

  task :delete_env_file do
    puts ">> Delete env file #{DOCKER_ENV_FILE}"
    DOCKER_ENV_FILE.tap do |env_file|
      File.delete(env_file) if File.exist?(env_file)
    end
  end

  task :create_env do |task|
    NECESSARY_SOFT.each do |bin|
      find_executable(bin) || abort("\e[31m#{bin} not found\e[0m")
    end
    Rake::Task["#{task.scope.path}:delete_env_file"].execute
    Rake::Task["#{task.scope.path}:create_env_file"].execute
  end

  desc 'build service'
  task :build do |task|
    puts '>> Run docker-compose build'
    Rake::Task["#{task.scope.path}:stop"].execute
    Rake::Task["#{task.scope.path}:create_env"].execute
    system('docker-compose build')
  end

  desc 'run service'
  task :run do |task|
    Rake::Task["#{task.scope.path}:create_env"].execute
    system('docker-compose up -d')
  end

  desc 'stop service'
  task :stop do |task|
    Rake::Task["#{task.scope.path}:create_env"].execute
    system('docker-compose stop')
    system('docker-compose rm -f')
    Rake::Task["#{task.scope.path}:delete_env_file"].execute
  end

  desc "enter #{UNICORN_CONTAINER} container"
  task :enter do |task|
    Rake::Task["#{task.scope.path}:run"].execute
    puts ">> Enter #{UNICORN_CONTAINER}"
    system("docker exec -it #{UNICORN_CONTAINER} sh")
  end
end
