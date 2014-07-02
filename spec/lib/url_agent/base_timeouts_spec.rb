require_relative '../../spec_helper'

require 'em-synchrony'

describe URLAgent::Base, :slow => true do
  URL_AGENT_TIMEOUT_PATH_ROOT = Pathname.new(File.dirname(__FILE__)).join("..", "..", "..", "spec")
  URL_AGENT_SERVER_TIMEOUT_DELAY = 0.25
  URL_AGENT_SERVER_PORT = 10002

  let(:url_agent) { URLAgent::Base.instance }
  
  def time_taken_for
    start_time = Time.now
    yield if block_given?
    end_time = Time.now
    
    (end_time - start_time)
  end

  context "when processing slow urls and timeouts" do
    before do
      url_agent.configure!(:path_root => URL_AGENT_TIMEOUT_PATH_ROOT)
    end
    
    it "should work well with a url that is normal and instant" do
      EM.synchrony do
        s = StubServer.new("HTTP/1.0 200 OK\r\nConnection: close\r\n\r\nHello World\n", URL_AGENT_SERVER_TIMEOUT_DELAY, URL_AGENT_SERVER_PORT)
        
        url_agent[:dummy_normal].call.response.should == "Hello World\n"
        
        s.stop
        EM.stop
      end
    end

    it "should work with slow urls" do
      EM.synchrony do
        s = StubServer.new("HTTP/1.0 200 OK\r\nConnection: close\r\n\r\nHello World\n", 1, URL_AGENT_SERVER_PORT)

        time_taken_for do
          url_agent[:dummy_slow].call.response.should == "Hello World\n"
        end.should be_within(0.2).of(1)
        
        s.stop
        EM.stop
      end
    end
    
    it "should return an error on a timeout url" do
      EM.synchrony do
        s = StubServer.new("HTTP/1.0 200 OK\r\nConnection: close\r\n\r\nHello World\n", 20, URL_AGENT_SERVER_PORT)

        time_taken_for do
          lambda { url_agent[:dummy_timeout].call }.should raise_error(URLAgent::ConnectionError)
        end.should be_within(0.2).of(2)

        s.stop
        EM.stop
      end
    end
    
    it "should return an error when the URL can't be reached" do
      EM.synchrony do
        lambda { url_agent[:dummy_nonexistent].call }.should raise_error URLAgent::ConnectionError
        
        EM.stop
      end
    end
  end
end
