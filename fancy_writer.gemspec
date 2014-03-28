# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fancy_writer/version'

Gem::Specification.new do |spec|
  spec.name          = "fancy_writer"
  spec.version       = FancyWriter::VERSION
  spec.authors       = ["Peter Menke"]
  spec.email         = ["pmenke@googlemail.com"]
  spec.summary       = %q{A simple IO wrapper for easier comment blocks, indentation and CSV output.}
  spec.description   = %q{FancyWriter is a wrapper around an IO object that allows you to augment text blocks with whitespace indentation and comment symbols, and to format simple CSV data series. }
  spec.homepage      = "https://github.com/pmenke/fancy_writer"
  spec.license       = "GNU LGPL 3"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
