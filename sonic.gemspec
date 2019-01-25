# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sonic/version"

Gem::Specification.new do |spec|
  spec.name          = "sonic-screwdriver"
  spec.version       = Sonic::VERSION
  spec.authors       = ["Tung Nguyen"]
  spec.email         = ["tung@boltops.com"]
  spec.summary       = "Multi-functional tool to manage AWS infrastructure"
  spec.homepage      = "http://sonic-screwdriver.cloud/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "aws-sdk-ec2"
  spec.add_dependency "aws-sdk-ecs"
  spec.add_dependency "aws-sdk-s3"
  spec.add_dependency "aws-sdk-ssm"
  spec.add_dependency "hashie"
  spec.add_dependency "memoist"
  spec.add_dependency "rainbow"
  spec.add_dependency "thor"
  spec.add_dependency "tty-prompt"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-bundler"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "cli_markdown"
end
