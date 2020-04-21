# frozen_string_literal: true

require 'logger'

require_relative File.expand_path('../conf', __dir__)

# Log
class Log
  LOG_LEVEL = ReporterConf::LOG_LEVEL

  def self.logger
    Logger.new($stdout).tap do |log|
      log.level = LOG_LEVEL.call
    end
  end
end
