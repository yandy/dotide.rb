# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dotide/version'

Gem::Specification.new do |spec|
  spec.name          = "dotide"
  spec.version       = Dotide::VERSION.dup
  spec.authors       = ["Michael Ding"]
  spec.email         = ["yandy.ding@gmail.com"]
  spec.description   = %q{Simple wrapper for the Dotide API}
  spec.summary       = "Ruby toolkit for working with the Dotide API"
  spec.homepage      = "https://github.com/dotide/dotide.rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'sawyer', '~> 0.5.1'
  spec.add_development_dependency "bundler", "~> 1.3"
end
