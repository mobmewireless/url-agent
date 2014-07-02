require_relative '../../spec_helper'

require 'em-synchrony'

describe URLAgent::Pinger do

  let(:dispatcher) { double(
    :get => double("Response", :response => "Response"), 
    :execute_request => double("Execute Request", :response => "Response")) 
  }
  let(:valid_response) { double('Response', { :response => "Hello World" }) }

  before do
    @google = URLAgent::UrlSet.new({
        :active => "http://www.google.co.in/search?client=%%client%%&q=%%query%%",
        :backup => "http://www.google.com/search?client=%%client%%&q=%%query%%",
        :uk => "http://www.google.co.uk/search?client=%%client%%&q=%%query%%",
        :lk => "http://www.google.co.lk/search?client=%%client%%&q=%%query%%",
        :ie => "http://www.google.co.ie/search?client=%%client%%&q=%%query%%"
    }, :url_set_identifier => :google, :dispatcher => dispatcher)
    
    urls = {
      :google => @google
    }
    
    pinger_configuration = {
        :google => {
          'verb' => "get",
          'params' => {
            'client' => "safari",
            'query'  =>  "hello"
          },
          'response' => "Hello World"
        },
        :tick => 0.5
    }
    
    @logger = double('Logger', :debug => true, :info => true, :warn => true, :error => true, :fatal => true, :unknown => true) 
    @pinger = URLAgent::Pinger.new(urls, pinger_configuration)
    URLAgent.stub(:logger).and_return(@logger)
  end

  it "continuously performs checks at configurable ticks" do
    EM.synchrony do
      @pinger.should_receive(:check).exactly(3).times
      
      @pinger.monitor
      EM::Synchrony.sleep(1.6)
      
      EM.stop
    end
  end

  describe "#check" do
    it "builds each url in the configuration for errors with the specified parameters" do      
      @google.urls.each do |identifier, url|
        url.should_receive(:build).with({:client => "safari", :query => "hello"}).and_return(url)
      end
      
      @pinger.check
    end
    
    it "dispatches correct requests to the dispatcher and awaits response" do
      dispatcher.should_receive(:execute_request).with(:get, "google:active", "http://www.google.co.in/search?client=safari&q=hello", {}).and_return(valid_response)
      dispatcher.should_receive(:execute_request).with(:get, "google:backup", "http://www.google.com/search?client=safari&q=hello", {}).and_return(valid_response)
      
      @pinger.check
    end
    
    it "marks urls that can't be times out to as dead" do
      dispatcher.should_receive(:execute_request).with(:get, "google:active", "http://www.google.co.in/search?client=safari&q=hello", {}).and_raise(URLAgent::TimeoutException)
      dispatcher.should_receive(:execute_request).with(:get, "google:backup", "http://www.google.com/search?client=safari&q=hello", {}).and_return(valid_response)
      
      @pinger.check
      
      @google.active.to_s.should_not == "http://www.google.co.in/search?client=%%client%%&q=%%query%%"
      @google.active.to_s.should == "http://www.google.com/search?client=%%client%%&q=%%query%%"
    end
    
    it "marks urls that can't be connected to as dead" do
      dispatcher.should_receive(:execute_request).with(:get, "google:active", "http://www.google.co.in/search?client=safari&q=hello", {}).and_raise(URLAgent::ConnectionError)
      dispatcher.should_receive(:execute_request).with(:get, "google:backup", "http://www.google.com/search?client=safari&q=hello", {}).and_return(valid_response)
      
      @pinger.check
      
      @google.active.to_s.should_not == "http://www.google.co.in/search?client=%%client%%&q=%%query%%"
      @google.active.to_s.should == "http://www.google.com/search?client=%%client%%&q=%%query%%"
    end
    
    it "marks urls that come back up as alive" do
      dispatcher.should_receive(:execute_request).with(:get, "google:active", "http://www.google.co.in/search?client=safari&q=hello", {}).and_raise(URLAgent::ConnectionError)
      dispatcher.should_receive(:execute_request).with(:get, "google:backup", "http://www.google.com/search?client=safari&q=hello", {}).and_return(valid_response)
      
      @pinger.check
      
      dispatcher.should_receive(:execute_request).with(:get, "google:active", "http://www.google.co.in/search?client=safari&q=hello", {}).and_return(valid_response)
      dispatcher.should_receive(:execute_request).with(:get, "google:backup", "http://www.google.com/search?client=safari&q=hello", {}).and_return(valid_response)
      
      @pinger.check
      
      @google.active.to_s.should_not == "http://www.google.com/search?client=%%client%%&q=%%query%%"
      @google.active.to_s.should == "http://www.google.co.in/search?client=%%client%%&q=%%query%%"
    end
    
    context "when some urls are alive and some are dead" do
      it "correctly marks the dead urls as dead and the alive ones as still alive" do
        dispatcher.should_receive(:execute_request).with(:get, "google:active", "http://www.google.co.in/search?client=safari&q=hello", {}).and_return(valid_response)
        dispatcher.should_receive(:execute_request).with(:get, "google:backup", "http://www.google.com/search?client=safari&q=hello", {}).and_raise(URLAgent::ConnectionError)
        dispatcher.should_receive(:execute_request).with(:get, "google:uk", "http://www.google.co.uk/search?client=safari&q=hello", {}).and_return(valid_response)
        dispatcher.should_receive(:execute_request).with(:get, "google:lk", "http://www.google.co.lk/search?client=safari&q=hello", {}).and_raise(URLAgent::ConnectionError)
        dispatcher.should_receive(:execute_request).with(:get, "google:ie","http://www.google.co.ie/search?client=safari&q=hello", {}).and_return(valid_response)
        
        @pinger.check
        
        @google.urls[:active].live.should == true
        @google.urls[:backup].live.should == false
        @google.urls[:uk].live.should == true
        @google.urls[:lk].live.should == false
        @google.urls[:ie].live.should == true
      end
    end
    
    describe "logging" do
      it "should make available a logger" do
        @pinger.should respond_to :logger
      end
      
      context "while checking urls" do        
        it "should log all urls that are checked on debug" do
          @logger.should_receive(:debug).with(%r(CHECK\tgoogle:active\thttp://www.google.co.in/search\?client=safari&q=hello))
          @logger.should_receive(:debug).with(%r(CHECK\tgoogle:backup\thttp://www.google.com/search\?client=safari&q=hello))
          @logger.should_receive(:debug).with(%r(CHECK\tgoogle:uk\thttp://www.google.co.uk/search\?client=safari&q=hello))
          @logger.should_receive(:debug).with(%r(CHECK\tgoogle:lk\thttp://www.google.co.lk/search\?client=safari&q=hello))
          @logger.should_receive(:debug).with(%r(CHECK\tgoogle:ie\thttp://www.google.co.ie/search\?client=safari&q=hello))
          
          @pinger.check
        end
        
        it "should log dead urls with a warning" do
          dispatcher.should_receive(:execute_request).with(:get, "google:active", "http://www.google.co.in/search?client=safari&q=hello", {}).and_raise(URLAgent::ConnectionError)
          dispatcher.should_receive(:execute_request).with(:get, "google:backup", "http://www.google.com/search?client=safari&q=hello", {}).and_raise(URLAgent::TimeoutException)
          
          @logger.should_receive(:warn).with(%r(DEAD\tgoogle:active\thttp://www.google.co.in/search\?client=safari&q=hello\tConnection Error))
          @logger.should_receive(:warn).with(%r(DEAD\tgoogle:backup\thttp://www.google.com/search\?client=safari&q=hello\tTimeout Exception))
          
          @pinger.check
        end
        
        it "should log urls that are alive as info" do
          @logger.should_receive(:info).with(%r(ALIVE\tgoogle:active\thttp://www.google.co.in/search\?client=safari&q=hello))
          
          @pinger.check
        end
        
        it "should log url responses on debug" do
          @logger.should_receive(:debug).with(%r(CHECK-RESPONSE\tgoogle:active\thttp://www.google.co.in/search\?client=safari&q=hello\t8\t"Response"))
          
          @pinger.check
        end
      end
    end
  end
end
