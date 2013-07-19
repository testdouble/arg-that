# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arg_that/version'

Gem::Specification.new do |spec|
  spec.name          = "arg-that"
  spec.version       = ArgThat::VERSION
  spec.authors       = ["Justin Searls"]
  spec.email         = ["searls@gmail.com"]
  spec.description   = %q{arg-that provides a simple method to create an argument matcher in equality comparisons.}
  spec.summary       = %q{arg-that provides a simple method to create an argument matcher in equality comparisons. This is particularly handy when writing a test to assert the equality of some complex data struct with another and only one component is difficult or unwise to assert exactly.}
  spec.homepage      = "http://github.com/testdouble/arg-that"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
end
