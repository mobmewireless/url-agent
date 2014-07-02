require 'active_support/core_ext/hash'

class URLAgent::Pinger
  attr_accessor :url_sets, :pinger_configuration, :tick
  
  def initialize(url_sets, pinger_configuration)
    @url_sets = url_sets
    @pinger_configuration = pinger_configuration
    @tick = @pinger_configuration[:tick] || 10
  end
  
  def monitor
    return unless EM.reactor_running?
    
    logger.debug "MONITOR"
    EM.add_periodic_timer(@tick) { Fiber.new { check }.resume }
  end
  
  def check
    @url_sets.each do |url_set_identifier, set|     
      url_configuration = pinger_configuration[url_set_identifier] 
      url_parameters = url_configuration["params"].symbolize_keys
      http_verb = (url_configuration['verb'] || "get").to_sym
      
      set.urls.each do |url_identifier, url|
        begin
          url_built = url.build(url_parameters)
          
          logger.debug "CHECK\t#{url_set_identifier}:#{url_identifier}\t#{url_built}"
          connection = url_built.send(http_verb)
          logger.debug "CHECK-RESPONSE\t#{url_set_identifier}:#{url_identifier}\t#{url_built}\t#{connection.response.length}\t#{connection.response.inspect[0..200]}"
          
          logger.info "ALIVE\t#{url_set_identifier}:#{url_identifier}\t#{url_built}"
          url.alive!
        rescue URLAgent::ConnectionError
          logger.warn "DEAD\t#{url_set_identifier}:#{url_identifier}\t#{url_built}\tConnection Error"
          url.dead!
        rescue URLAgent::TimeoutException
          logger.warn "DEAD\t#{url_set_identifier}:#{url_identifier}\t#{url_built}\tTimeout Exception"
          url.dead!
        end
      end
    end
  end
  
  def logger
    URLAgent.logger
  end
end
