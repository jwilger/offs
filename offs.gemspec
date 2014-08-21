# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'offs/version'

Gem::Specification.new do |spec|
  spec.name          = "offs"
  spec.version       = OFFS::VERSION
  spec.authors       = ["John Wilger"]
  spec.email         = ["johnwilger@gmail.com"]
  spec.summary       = %q{OFFS Feature Flagging System}
  spec.description   = %q{OFFS provides a means to demarcate code that is
                          related to new features as well as the old code path
                          and switch between the two depending on
                          configuration.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "injectable_dependencies"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
