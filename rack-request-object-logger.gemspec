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

  spec.summary       = %q{Log HTTP requests via Rack stack to an object. You can use any object.}
  spec.description   = %q{Log HTTP requests via Rack stack to an object. You can use any object, i.e. ActiveRecord model}
  spec.homepage      = "https://github.com/starmammoth/rack-request-object-logger"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", "> 0", "< 3.0"
  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "rspec-benchmark", "~> 0"
  spec.add_development_dependency "pry", "~> 0"
  spec.add_development_dependency "activerecord", '>= 6.0', "< 7.0"
  spec.add_development_dependency "sqlite3", "~> 1.4" unless RUBY_PLATFORM == 'java'
  spec.add_development_dependency "mysql2", "~> 0.5" unless RUBY_PLATFORM == 'java'
end
