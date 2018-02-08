# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sonic/version'

Gem::Specification.new do |spec|
  spec.name          = "sonic-screwdriver"
  spec.version       = Sonic::VERSION
  spec.authors       = ["Tung Nguyen"]
  spec.email         = ["tung@boltops.com"]
  spec.description   = %q{Multi-functional tool to manage AWS infrastructure}
  spec.summary       = %q{Multi-functional tool to manage AWS infrastructure}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "hashie"
  spec.add_dependency "colorize"
  spec.add_dependency "aws-sdk-ec2"
  spec.add_dependency "aws-sdk-ecs"
  spec.add_dependency "aws-sdk-ssm"
  spec.add_dependency "tty-prompt"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-bundler"
  spec.add_development_dependency "guard-rspec"
end
