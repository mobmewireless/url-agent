require 'singleton'
require 'logger'
require 'yaml'
require 'uri'
require 'active_support/core_ext/hash'

require_relative 'dispatcher'

class URLAgent::Base
  include Singleton

  attr_reader :logger, :pinger
  attr_accessor :urls

  def initialize(options = {})
    @configured = false
    @options = options
  end

  def configure(options = {})
    return if configured?
    configure!(options)
  end

  def configure!(options)
    URLAgent.root = options[:path_root]

    unless url_configuration_file.exist?
      raise URLAgent::ConfigurationNotFoundException, "Cannot find #{url_configuration_file}"
    end

    @evented = begin
      require_eventmachine_libraries
    rescue LoadError
      false
    end

    @urls ||= {}

    url_configuration_load
    initialize_logger

    load_dispatcher
    initialize_urls
    configure_pinger

    @configured = true
  end

  def configured?
    @configured
  end

  def evented?
    @evented
  end

  def [](identifier)
    raise URLAgent::IdentifierNotFoundException unless @urls[identifier]

    @urls[identifier].active
  end

  private

  def initialize_logger
    return unless @options[:logger]

    logger_file = URLAgent.root.join(@options[:logger][:path])
    log_level = if @options[:verbose]
                  :DEBUG
                else
                  @options[:logger][:log_level]
                end.upcase.to_sym

    raise URLAgent::LogDirectoryNotPresent unless logger_file.dirname.exist?

    @logger = URLAgent::Logger.new(logger_file)
    @logger.info "URL Agent starting up..."
    @logger.info "Log level is #{log_level}"
    @logger.level = ActiveSupport::Logger::Severity.const_get(log_level)

    # Set this up as a logger available at the root
    URLAgent.logger = @logger
  end

  def initialize_urls
    @urls = Hash[@urls.map { |key, data| [key, URLAgent::UrlSet.new(data, :url_set_identifier => key, :dispatcher => @dispatcher)] }]
  end

  def url_configuration_file
    URLAgent.root.join('config', 'urls.yaml')
  end

  def require_eventmachine_libraries
    require 'em-http-request'
    require 'em-synchrony'
    require 'em-synchrony/em-http'

    # We don't test for reactor_running? here, that's defered to the call method
    true
  end

  def url_configuration_load
    @urls = {}
    url_configuration = File.open(url_configuration_file, 'r') { |f| YAML.load(f.read) }
    url_configuration.symbolize_keys!

    url_configuration.each do |identifier, data|
      case identifier
      when :logger
        @options[:logger] = data.with_indifferent_access
      when :pinger
        @options[:pinger] = data.with_indifferent_access
      when :timeouts
        @options[:timeouts] = data.with_indifferent_access
      else
        @urls[identifier] = data
      end
    end
  end

  def load_dispatcher
    type = if evented?
             :em_http
           else
             :net_http
           end

    logger.info "Using #{type} dispatcher"

    @dispatcher = URLAgent::Dispatcher.new(@options.merge({ :type => type }))
  end

  def configure_pinger
    return unless evented?
    return unless @options[:pinger]

    @pinger = URLAgent::Pinger.new(@urls, @options[:pinger])

    logger.info "Pinger started"
    @pinger.monitor
  end
end
