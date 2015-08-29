# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'object_tracker/version'

Gem::Specification.new do |spec|
  spec.name          = "object_tracker"
  spec.version       = ObjectTracker::VERSION
  spec.authors       = ["Ryan Buckley"]
  spec.email         = ["arebuckley@gmail.com"]
  spec.summary       = %q{Track method calls to almost any object.}
  spec.description   = %q{Track method calls to almost any object. Class and instance methods can be tracked (w/ arguments).}
  spec.homepage      = 'https://github.com/ridiculous/object_tracker'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
