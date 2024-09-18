# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack-request-object-logger/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-request-object-logger"
  spec.version       = RackRequestObjectLogger::VERSION
  spec.authors       = ["Ivan Stana"]
  spec.email         = ["ronon@myrtana.sk"]

  spec.summary       = %q{The project is a Rack middleware to automatically log a HTTP request to a custom object.}
  spec.description   = %q{The project is a Rack middleware to automatically log a HTTP request to a custom object.}
  spec.homepage      = "https://github.com/istana/rack-request-object-logger"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|performance)/})
  end
  spec.require_paths = ["lib"]

  spec.metadata = {
    "bug_tracker_uri"   => "https://github.com/istana/rack-request-object-logger/issues",
    "homepage_uri"      => "https://github.com/istana/rack-request-object-logger",
    "source_code_uri"   => "https://github.com/istana/rack-request-object-logger",
  }

  spec.add_dependency "rack", "> 0", "< 4.0"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rspec-benchmark", "~> 0"
  spec.add_development_dependency "pry", "~> 0"
  spec.add_development_dependency "activerecord", '>= 6.0', "< 8.0"
  spec.add_development_dependency "sqlite3", "<= 2.1" unless RUBY_PLATFORM == "java"
end



