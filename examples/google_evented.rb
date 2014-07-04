$:.push(File.expand_path(File.dirname(__FILE__) + '/../lib'))

require 'em-synchrony'
require 'em-http-request'
require 'em-synchrony/em-http'

require 'url-agent'

puts 'Tail logs/urls.log for something interesting to see!'

EM.synchrony do
  url_agent = URLAgent::Base.instance
  url_agent.configure(:path_root => File.dirname(__FILE__), :logger => Logger.new(STDOUT))
  
  response = url_agent[:google].get
  EM.add_timer(2) { print "." }
  EM.add_timer(20) { EM.stop }
end

puts 'Whoa! Done.'
