$:.unshift(File.expand_path("../", __FILE__))
require "sonic/version"
require "colorize"

module Sonic
  autoload :AwsService, 'sonic/aws_service'
  autoload :CLI, 'sonic/cli'
  autoload :Command, 'sonic/command'
  autoload :Docker, 'sonic/docker'
  autoload :Execute, 'sonic/execute'
  autoload :List, 'sonic/list'
  autoload :Setting, 'sonic/setting'
  autoload :Ssh, 'sonic/ssh'
  autoload :UI, 'sonic/ui'
  autoload :Checks, 'sonic/checks'
end
