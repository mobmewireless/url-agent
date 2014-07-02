
class URLAgent::EMHTTPDispatcher
  def initialize(url_agent_options)
    @connection_options ||= {} 
    
    if url_agent_options[:timeouts]
      @connection_options[:connect_timeout] = url_agent_options[:timeouts][:connection]
      @connection_options[:inactivity_timeout] = url_agent_options[:timeouts][:inactivity]
    end
  end
  
  def execute_request(http_verb, url_name, url, request_options = {})
    check_for_eventmachine!
    
    logger.debug "#{http_verb.upcase}\t#{url_name}\t#{url}\t#{request_options.inspect}"
    
    request = EventMachine::HttpRequest.new(url, @connection_options).send(http_verb, request_options)
    
    unless request.error.to_s.empty?
      logger.error "#{http_verb.upcase}\t#{url_name}\t#{url}\t#{request_options.inspect}\tConnection Error"
      raise URLAgent::ConnectionError, request.error
    end
      
    unless request.finished?
      logger.error "#{http_verb.upcase}\t#{url_name}\t#{url}\t#{request_options.inspect}\tTimeout Exception"
      raise URLAgent::TimeoutException
    end
    
    logger.debug "#{http_verb.upcase}-RESPONSE\t#{url_name}\t#{url}\t#{request_options.inspect}\t#{request.response.length}\t#{request.response.inspect[0..200]}"
    
    request
  end
  
  def logger
    URLAgent.logger
  end
  
  private
  def check_for_eventmachine!(&block)
    unless EM.reactor_running?
      raise URLAgent::EMHTTPDispatcherReactorNotRunning, "The reactor is not running. You should wrap calls to the EMHTTPDispatcher around a EM.synchrony block"
    end
  end
end
