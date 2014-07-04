## Description

URL Agent acts as a proxy for managing URL access for applications. 

## Usage

    config/urls.yaml:
      cos:
        - http://10.444.233.1/?msisdn=%msisdn%
        - http://10.444.233.7/?msisdn=%msisdn%
      google:
        - http://google.com/?q=msisdn=%msisdn%
    
    test:rb:
      require 'url-agent'    
      url_agent = URLAgent::Base.instance
      url_agent.configure(:path_root => File.dirname(__FILE__), :logger => Logger.new(STDOUT))
      
      response = ""
      EM.synchrony do
        response = url-agent[:google].get
        EM.add_timer(3) { EM.stop }
      end

      puts response.response
      
See examples/google_evented.rb for a complete working example.

## Run Tests

To run tests, run the slow server first:

    $ rackup spec/server/dummy.ru
    $ bundle exec rspec spec

## Install

Install rvm and ruby-1.9.2

Then do:

    $ gem install bundler
    $ bundle install --path vendor
    $ bundle package

## Deployment

This is a library, and is meant to be used included in other projects.
