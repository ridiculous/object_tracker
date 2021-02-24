# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'object_tracker/version'

Gem::Specification.new do |spec|
  spec.name          = "object_tracker"
  spec.version       = ObjectTracker::VERSION
  spec.authors       = ["Ryan Buckley"]
  spec.email         = ["arebuckley@gmail.com"]
  spec.summary       = %q{Track method calls to any object.}
  spec.description   = %q{Track method calls to any object. Class and instance methods can be tracked (w/ arguments and source location).}
  spec.homepage      = 'https://github.com/ridiculous/object_tracker'
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/).keep_if { |f| f =~ /object_tracker/ and f !~ %r{test/} }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.2.11"
  spec.add_development_dependency "rake", ">= 12.3.3"

  spec.required_ruby_version = '>= 2.0.0'
end
