require_relative '../../spec_helper'

describe URLAgent::Url do
  let(:dispatcher) { double('Dispatcher', { :execute_request => nil }) }
  
  describe "#build" do
    it "should replace %%parameters%% with the parameter in the argument" do
      url = URLAgent::Url.new("http://g.com/%%param%%", :dispatcher => dispatcher)
      
      url.build(:param => "hello").to_s.should == "http://g.com/hello"
    end
  
    it "should work with numeric arguments" do
      url = URLAgent::Url.new("http://g.com/%%param%%", :dispatcher => dispatcher)
      
      url.build({ :param => 23 }).to_s.should == "http://g.com/23"
    end
  
    it "should replace multiple arguments in a hash" do
      url = URLAgent::Url.new("http://g.com/?a=%%param1%%&b=%%param2%%", :dispatcher => dispatcher)
      
      url.build({ :param1 => "hello", :param2 => "world" }).to_s.should == "http://g.com/?a=hello&b=world"
    end
  
    it "should escape arguments" do
      url = URLAgent::Url.new("http://g.com/%%param%%", :dispatcher => dispatcher)
      
      url.build({ :param => "hello world" }).to_s.should == "http://g.com/hello%20world"
    end
  end
end
