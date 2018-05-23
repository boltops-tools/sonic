require 'yaml'

module Sonic
  class Setting
    def data
      return @data if @data

      project_file = "#{Sonic.root}/.sonic/settings.yml"
      project = File.exist?(project_file) ? load_yaml_file(project_file) : {}

      user_file = "#{home}/.sonic/settings.yml"
      user = File.exist?(user_file) ? load_yaml_file(user_file) : {}

      default_file = File.expand_path("../default/settings.yml", __FILE__)
      default = load_yaml_file(default_file)

      @data = default.merge(user.merge(project))[Sonic.env]

      ensure_default_cluster!(@data)

      @data
    end

    # Any empty file will result in "false".  Lets ensure that an empty file
    # loads an empty hash instead.
    def load_yaml_file(path)
      YAML.load_file(path) || {}
    end

    # Public: Returns default cluster based on the ECS service name.
    #
    # service  - ECS service
    # count - The Integer number of times to duplicate the text.
    #
    # The settings.yml format:
    #
    # service_cluster:
    #   default: stag
    #   hi-web-prod: prod
    #   hi-clock-prod: prod
    #   hi-worker-prod: prod
    #   hi-web-stag: stag
    #   hi-clock-stag: stag
    #   hi-worker-stag: stag
    #
    # Examples
    #
    #   default_cluster('hi-web-prod')
    #   # => 'prod'
    #   default_cluster('whatever')
    #   # => 'stag'
    #
    # Returns the ECS cluster name.
    def default_cluster(service)
      service_cluster = data["service_cluster"]
      service_cluster[service] || service_cluster["default"]
    end

    # When user's .sonic/settings.yml lack the default cluster, we add it on.
    # Otherwise the user get confusing and scary aws-sdk-core/param_validator errors:
    # Example: https://gist.github.com/sonic/67b9a68a77363b908d1c36047bc2709a
    def ensure_default_cluster!(data)
      unless data["service_cluster"]["default"]
        data["service_cluster"]["default"] = "default"
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
    #   default_bastion('stag')
    #   # => 'bastion-stag.mydomain.com'
    #   default_bastion('whatever')
    #   # => 'bastion.mydomain.com'
    #
    # Returns the bastion host that is mapped to the cluster
    def default_bastion(cluster)
      data["bastion"]
    end

    # By default bypass strict host key checking for convenience.
    # But user can overrride this.
    def host_key_check_options
      if data["host_key_check"] == true
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
