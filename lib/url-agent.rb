require 'pathname'
require 'logger'

module URLAgent
  class << self
    attr_reader :root
    attr_accessor :logger

    def root=(path)
      @root = Pathname.new("#{File.expand_path(path || Dir.pwd)}").realdirpath
    end
  end
end

require_relative 'url_agent/logger'
require_relative 'url_agent/exceptions'
require_relative 'url_agent/url'
require_relative 'url_agent/url_set'
require_relative 'url_agent/base'
require_relative 'url_agent/pinger'
