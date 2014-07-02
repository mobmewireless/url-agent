class URLAgent::Dispatcher
  attr_reader :proxy
  
  def initialize(options = {})
    type = options.delete(:type) || :net_http
    @proxy = case type
      when :net_http
        require_relative 'dispatcher/net_http'
        URLAgent::NetHTTPDispatcher.new(options)
      when :em_http
        require_relative 'dispatcher/em_http'
        URLAgent::EMHTTPDispatcher.new(options)
      end
  end
  
  def execute_request(http_verb, url_name, url, request_options = {})
    @proxy.execute_request(http_verb, url_name, url, request_options)
  end
end

