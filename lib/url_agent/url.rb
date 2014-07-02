class URLAgent::Url
  attr_accessor :live

  def initialize(url, options = {})
    @url = url

    @dispatcher = options[:dispatcher]
    @live = options[:live].nil? ? true : options[:live]
    @url_set_identifier = options[:url_set_identifier]
    @identifier = options[:identifier]

    unless @dispatcher
      raise ArgumentError, "Must provide a dispatcher to construct a callable URL."
    end
  end

  def build(parameters = {})
    url_with_parameters = @url.dup
    parameters.each do |parameter_name, parameter_value|
      url_with_parameters.gsub!("%%#{parameter_name}%%", URI.escape("#{parameter_value}"))
    end

    self.class.new(url_with_parameters, { :dispatcher => @dispatcher, :live => @live, :url_set_identifier => @url_set_identifier, :identifier => @identifier })
  end

  def to_s
    @url.to_s
  end

  [:get, :head, :post, :put].each do |http_verb|
    self.class_eval do
      define_method http_verb do |request_options = {}|
        logger.debug "DISPATCH\t#{url_name}\t#{self.to_s}\t#{__method__.upcase}"
        @dispatcher.execute_request(http_verb, url_name, self.to_s, request_options)
      end
    end
  end

  alias :call :get

  def dead!
    @live = false
  end

  def alive!
    @live = true
  end

  def alive?
    @live
  end

  def logger
    URLAgent.logger
  end

  def url_name
    "#{@url_set_identifier}:#{@identifier}"
  end
end
