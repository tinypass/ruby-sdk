# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tinypass/version'

Gem::Specification.new do |spec|
  spec.name          = "tinypass"
  spec.version       = Tinypass::VERSION
  spec.authors       = ["Taavo Smith"]
  spec.email         = ["taavo@dd9.com"]
  spec.description   = "Tinypass Ruby SDK"
  spec.summary       = "Tinypass Ruby SDK"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client", "~> 1.4"
  spec.add_dependency "multi_json", ">= 1.0.4", "< 2"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "nokogiri"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "webmock"

  # used only for acceptance tests
  spec.add_development_dependency "poltergeist"
  spec.add_development_dependency "dotenv"
end
