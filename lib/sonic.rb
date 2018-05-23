$:.unshift(File.expand_path("../", __FILE__))
require "sonic/version"
require "colorize"

module Sonic
  autoload :Core, 'sonic/core'
  autoload :Help, 'sonic/help'
  autoload :AwsService, 'sonic/aws_service'
  autoload :CLI, 'sonic/cli'
  autoload :Command, 'sonic/command'
  autoload :Docker, 'sonic/docker'
  autoload :RunCommand, 'sonic/run_command'
  autoload :List, 'sonic/list'
  autoload :Setting, 'sonic/setting'
  autoload :Ssh, 'sonic/ssh'
  autoload :UI, 'sonic/ui'
  autoload :Checks, 'sonic/checks'
  autoload :Completion, "sonic/completion"
  autoload :Completer, "sonic/completer"

  extend Core
end
