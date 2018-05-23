require 'pathname'
require 'yaml'

module Sonic
  module Core
    def root
      path = ENV['SONIC_ROOT'] || '.'
      Pathname.new(path)
    end

    @@env = nil
    def env
      return @@env if @@env
      sonic_env = env_from_profile(ENV['AWS_PROFILE']) || 'development'
      sonic_env = ENV['SONIC_ENV'] if ENV['SONIC_ENV'] # highest precedence
      @@env = sonic_env
    end

    private
    # Do not use the Setting class to load the profile because it can cause an
    # infinite loop then if we decide to use Sonic.env from within settings class.
    def env_from_profile(aws_profile)
      data = YAML.load_file("#{ENV['HOME']}/.sonic/settings.yml")
      env = data.find do |_env, setting|
        setting ||= {}
        profiles = setting['aws_profiles']
        profiles && profiles.include?(aws_profile)
      end
      env.first if env
    end
  end
end
