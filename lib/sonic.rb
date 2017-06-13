$:.unshift(File.expand_path("../", __FILE__))
require "sonic/version"

module Sonic
  autoload :Command, 'sonic/command'
  autoload :CLI, 'sonic/cli'
end