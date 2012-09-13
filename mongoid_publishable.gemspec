# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "mongoid/publishable/version"

Gem::Specification.new do |s|
  s.name          = "mongoid-publishable"
  s.version       = Mongoid::Publishable::VERSION
  s.authors       = ["Ryan Townsend"]
  s.email         = ["ryan@ryantownsend.co.uk"]
  s.description   = %q{A mixin for Mongoid document models allowing for publishing them after authentication}
  s.summary       = s.description
  s.homepage      = "https://github.com/ryantownsend/mongoid-publishable"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  
  s.add_dependency "mongoid"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
end
