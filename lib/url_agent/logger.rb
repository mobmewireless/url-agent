require 'active_support/core_ext/date_time'
require 'active_support/logger'

class URLAgent::Logger < ActiveSupport::Logger

  class ActiveSupport::Logger::SimpleFormatter
    def call(severity, time, progname, msg)
      msg = "#{Time.now.to_formatted_s(:db)}, #{severity} #{msg.strip}\n"
    end
  end
end