require_relative '../../spec_helper'

describe URLAgent::Base do

  def write_config_with_non_existant_logger!
    File.open('/path/config/urls.yaml', 'w') do |f|
      f.write('
logger:
  log_level: debug
  path: log/urls.log
')
    end
  end

  URL_AGENT_PATH_ROOT = Pathname.new(File.dirname(__FILE__)).join("..", "..", "..", "spec")

  let(:url_agent) { URLAgent::Base.instance }
  let(:dispatcher) { double(:get => "Response", :execute_request => "Response") }
  
  before(:each) {
    URLAgent::Dispatcher.stub(:new).and_return(dispatcher)
    
    @logger = double('Logger', :debug => true, :info => true, :warn => true, :error => true, :fatal => true, :unknown => true)
    URLAgent.stub(:logger).and_return(@logger)
    url_agent.stub(:logger).and_return(@logger)
  }
  
  context "when initiasing" do
    it "should be a singleton" do
      URLAgent::Base.should respond_to :instance
    end
  end
  
  describe "#configure" do
    it "should raise an error when configuration is not found" do
      lambda do
        url_agent.configure!(:path_root => "/tmp")
      end.should raise_error URLAgent::ConfigurationNotFoundException
    end
    
    it "should set the dispatcher to use em-http-request and em-synchrony when eventmachine libraries are loaded" do
      url_agent.stub(:require_eventmachine_libraries => true)
      url_agent.stub(:configure_pinger => true)
      
      url_agent.configure!(:path_root => URL_AGENT_PATH_ROOT)
      url_agent.evented?.should == true
    end
    
    it "should set the dispatcher to use net/http when eventmachine libraries are not laoded" do
      url_agent.stub(:require_eventmachine_libraries).and_raise(LoadError)
      
      url_agent.configure!(:path_root => URL_AGENT_PATH_ROOT)
      url_agent.evented?.should == false
    end
    
    it "should set itself as configured once configuruation has been successful" do
      url_agent.configure!(:path_root => URL_AGENT_PATH_ROOT)
      url_agent.configured?.should == true
    end
    
    it "should load urls from urls.yaml" do
      url_agent.configure!(:path_root => URL_AGENT_PATH_ROOT)
      url_agent.urls.keys.should include(:google)
    end
    
    it "should create appropriate dispatchers" do
      # evented
      url_agent.stub(:require_eventmachine_libraries => true)
      URLAgent::Dispatcher.should_receive(:new).with(hash_including({:type => :em_http}))
      url_agent.configure!(:path_root => URL_AGENT_PATH_ROOT)
      
      # not evented
      url_agent.stub(:require_eventmachine_libraries).and_raise(LoadError)
      URLAgent::Dispatcher.should_receive(:new).with(hash_including({:type => :net_http}))
      url_agent.configure!(:path_root => URL_AGENT_PATH_ROOT)
    end
    
    it "configures a pinger and then monitors it" do
      URLAgent::Pinger.any_instance.should_receive(:monitor)
      url_agent.stub(:require_eventmachine_libraries => true)
      
      url_agent.configure!(:path_root => URL_AGENT_PATH_ROOT)
    end
  end
  
  describe "#[]" do
    it "should return a callable url when a key is passed in" do
      url_agent.configure!(:path_root => URL_AGENT_PATH_ROOT)
      
      url_agent[:google].should respond_to :call
    end
    
    it "should raise an error when calling a URL that is not present" do
      url_agent.configure!(:path_root => URL_AGENT_PATH_ROOT)
      lambda do
        url_agent[:bing].call
      end.should raise_error URLAgent::IdentifierNotFoundException
    end
  end
  
  describe 'logging' do
    it 'raises exception when log directory is not present' do
      FakeFS do
        FileUtils.mkdir_p('/path/config')
        write_config_with_non_existant_logger!
        expect { url_agent.configure!(path_root: '/path') }.to raise_error URLAgent::LogDirectoryNotPresent
      end
    end
    it 'should make available a logger' do
      url_agent.configure!(path_root: URL_AGENT_PATH_ROOT)
      
      url_agent.logger.should respond_to :info
      url_agent.logger.should respond_to :debug
      
      url_agent.pinger.logger.should respond_to :info
      url_agent.pinger.logger.should respond_to :debug
    end
    
    it 'should log requests as debug' do
      url_agent.configure!(:path_root => URL_AGENT_PATH_ROOT)
      
      url_agent.logger.should_receive(:debug).with(%r(DISPATCH\tgoogle:active\thttp://www.google.co.in/search\?client=safari&q=hello\tGET))
      url_agent[:google].build(:client => 'safari', :query => 'hello').call
    end
  end
end
