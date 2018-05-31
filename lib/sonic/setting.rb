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

      data = default.deep_merge(user.deep_merge(project))
      ensure_default_cluster!(data)
      data
    end
    memoize :data

    # Any empty file will result in "false".  Lets ensure that an empty file
    # loads an empty hash instead.
    def yaml_file(path)
      return {} unless File.exist?(path)
      YAML.load_file(path) || {}
    end

    # Public: Returns default cluster based on the ECS service name.
    #
    # service  - ECS service
    # count - The Integer number of times to duplicate the text.
    #
    # The settings.yml format:
    #
    # service_cluster_map:
    #   default: staging
    #   hi-web: production
    #   hi-clock: production
    #   hi-worker: production
    #
    # Examples
    #
    #   default_cluster('hi-web')
    #   # => 'production'
    #   default_cluster('whatever')
    #   # => 'staging'
    #
    # Returns the ECS cluster name.
    def default_cluster(service)
      service_cluster = data["ecs_service_cluster_map"]
      service_cluster[service] || service_cluster["default"]
    end

    # When user's .sonic/settings.yml lack the default cluster, we add it on.
    # Otherwise the user get confusing and scary aws-sdk-core/param_validator errors:
    # Example: https://gist.github.com/sonic/67b9a68a77363b908d1c36047bc2709a
    def ensure_default_cluster!(data)
      unless data["ecs_service_cluster_map"]["default"]
        data["ecs_service_cluster_map"]["default"] = "default"
      end
      data
    end

    # Public: Returns default bastion host.
    #
    # cluster  - cluster provided by user
    #
    # The settings.yml format:
    #
    # bastion: bastion.mydomain.com
    #
    # Examples
    #
    #   default_bastion('staging')
    #   # => 'bastion-stag.mydomain.com'
    #   default_bastion('whatever')
    #   # => 'bastion.mydomain.com'
    #
    # Returns the bastion host that is mapped to the cluster
    def default_bastion(cluster)
      data["bastion"]["host"]
    end

    # By default bypass strict host key checking for convenience.
    # But user can overrride this.
    def host_key_check_options
      if data["bastion"]["host_key_check"] == true
        []
      else
        # disables host key checking
        %w[-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null]
      end
    end

    def home
      # hack but fast
      ENV['TEST'] ? "spec/fixtures/home" : ENV['HOME']
    end
  end
end
