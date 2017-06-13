require 'yaml'

module Sonic
  class Settings
    def initialize(project_root='.')
      @project_root = project_root
    end

    def data
      return @data if @data

      @data = defaults
      if File.exist?(settings_path)
        custom_data = YAML.load_file(settings_path)
        @data.merge!(custom_data)
        ensure_default_cluster(@data)
      end
      @data
    end

    def defaults
      {
        "user" => "ec2-user",
        "service_cluster" => {"default" => "default"}
      }
    end

    # When user's .sonic/settings.yml lack the default cluster, we add it on.
    # Otherwise the user get confusing and scary aws-sdk-core/param_validator errors:
    # Example: https://gist.github.com/sonic/67b9a68a77363b908d1c36047bc2709a
    def ensure_default_cluster(data)
      unless @data["service_cluster"]["default"]
        @data["service_cluster"]["default"] = "default"
      end
    end

    def settings_path
      "#{ENV['HOME']}/.sonic/settings.yml"
    end
  end
end
