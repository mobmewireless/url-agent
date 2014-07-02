require 'simplecov'
require 'simplecov-rcov'
require 'fakefs/safe'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start do 
  add_filter 'vendor' 
  add_filter 'examples'
  add_filter 'spec'
end if ENV["COVERAGE"]

require 'url_agent'
require 'stub_server'
