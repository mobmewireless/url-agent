require_relative '../../spec_helper'

describe URLAgent::UrlSet do
  URL_SET_URLS = {
    :active => 'http://www.google.co.in/search?client=%%client%%&q=%%query%%', 
    :backup => 'http://www.google.com/search?client=%%client%%&q=%%query%%'
  }
  
  let(:dispatcher) { double('Dispatcher', { :execute_request => nil }) }
  
  before do 
    @url_set = URLAgent::UrlSet.new(URL_SET_URLS, :dispatcher => dispatcher)
  end
  
  it "should construct a full URL from a parameterized one" do
    @url_set.send(:build, { :client => "iPhone", :query => "Hello" }).to_s.should == 'http://www.google.co.in/search?client=iPhone&q=Hello'
  end
  
  it "find the active url in the set" do
    @url_set.active.to_s.should == 'http://www.google.co.in/search?client=%%client%%&q=%%query%%'
  end
  
  it "must be possible to mark a URL in the set as dead or alive" do
    @url_set.dead!(:active)
  end  
end
