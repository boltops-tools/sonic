require 'pathname'
require 'yaml'

module Sonic
  module Core
    def root
      path = ENV['SONIC_ROOT'] || '.'
      Pathname.new(path)
    end

    def profile
      ENV['SONIC_PROFILE'] || ENV['AWS_PROFILE']
    end
  end
end
