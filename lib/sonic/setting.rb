require 'yaml'
require 'memoist'
require 'active_support/core_ext/hash'

module Sonic
  class Setting
    extend Memoist

    def data
      settings_file = Sonic.profile || 'default'
      settings_file += ".yml"

      project = yaml_file("#{Sonic.root}/.sonic/#{settings_file}")
      user = yaml_file("#{home}/.sonic/#{settings_file}")
      default_file = File.expand_path("../default/settings.yml", __FILE__)
      default = yaml_file(default_file)

      data = merge(default, user, project)

      if ENV['DEBUG_SETTINGS']
        puts "settings data:"
        pp data
      end
      data
    end
    memoize :data

    def merge(*hashes)
      hashes.inject({}) do |result, hash|
        # note: important to compact for keys with nil value
        result.deep_merge(hash.compact)
      end
    end

    # Any empty file will result in "false".  Lets ensure that an empty file
    # loads an empty hash instead.
    def yaml_file(path)
      return {} unless File.exist?(path)
      YAML.load_file(path) || {}
    end

    def home
      # hack but fast
      ENV['TEST'] ? "spec/fixtures/home" : ENV['HOME']
    end
  end
end
