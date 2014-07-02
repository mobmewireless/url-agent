
Gem::Specification.new do |s|
  s.name        = "url-agent"
  s.version     = "0.9.7"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Vishnu Gopal"]
  s.email       = ["vishnu@mobme.in"]
  s.homepage    = "http://www.mobme.in/"
  s.summary     = "URL Agent acts as a proxy for managing URL access for applications"
  s.description = "URL agent can handle common errors, concurrency and fallback for applications that call a large number of URLs."
 
  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency 'rack'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'simplecov-rcov'
  s.add_development_dependency 'flog'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'ci_reporter'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'

  s.add_dependency 'eventmachine', '~> 1.0.0.beta'
  s.add_dependency 'em-http-request'
  s.add_dependency 'em-synchrony'
  s.add_dependency 'activesupport'
 
  s.files        = Dir.glob("{lib,examples}/**/*") + %w(README.md)
  s.require_path = 'lib'
end
