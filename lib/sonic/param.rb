require 'yaml'

module Sonic
  class Param
    def initialize
      @path = "#{ENV['HOME']}/.sonic/params.yml"
    end

    def data
      return {} unless File.exist?(@path)

      data = YAML.load_file(@path)
      return {} unless data.is_a?(Hash)

      data[Sonic.env]
    end
  end
end
