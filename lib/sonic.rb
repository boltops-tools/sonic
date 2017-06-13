$:.unshift(File.expand_path("../", __FILE__))
require "sonic/version"
require "aws-sdk"

module Sonic
  autoload :Command, 'sonic/command'
  autoload :Settings, 'sonic/settings'
  autoload :Defaults, 'sonic/defaults'
  autoload :CLI, 'sonic/cli'
  autoload :AwsServices, 'sonic/aws_services'
  autoload :Ssh, 'sonic/ssh'
  autoload :Docker, 'sonic/docker'
end
