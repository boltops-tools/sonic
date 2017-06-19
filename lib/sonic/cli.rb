require 'thor'
require 'sonic/cli/help'

module Sonic
  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean
    class_option :cluster, desc: "ECS Cluster to use.  Default cluster is default"
    class_option :bastion, desc: "Bastion jump host to use.  Defaults to no bastion server."
    class_option :project_root, desc: "Project root. Useful for testing.", hide: true

    desc "ssh [IDENTIFER]", "ssh into a instance using identifier. identifer can be be service name or instance id"
    long_desc Help.ssh
    def ssh(service, *command)
      Ssh.new(service, options.merge(command: command)).run
    end

    desc "ecs-exec [ECS_SERVICE]", "docker exec into running docker container associated with the service on a container instance"
    long_desc Help.ecs_exec
    def ecs_exec(service, *command)
      Docker.new(service, options.merge(command: command)).exec
    end

    # Cannot name the command run because that is a reserved Thor keyword :(
    desc "ecs-run [ECS_SERVICE]", "docker run with the service on a container instance"
    long_desc Help.ecs_run
    def ecs_run(service, *command)
      Docker.new(service, options.merge(command: command)).run
    end

    stop_on_unknown_option! :execute
    check_unknown_options! :except => :execute
    desc "execute [COMMAND]", "runs command across fleet of servers via AWS Run Command"
    long_desc Help.execute
    option :filter, type: :string, required: true, desc: "Filter ec2 instances by tag name or instance_ids separated by commas"
    def execute(*command)
      Execute.new(command, options).execute
    end

    desc "list", "lists ec2 instances"
    long_desc Help.list
    option :header, type: :boolean, desc: "Displays header"
    option :filter, type: :string, desc: "Filter ec2 instances by tag name or instance_ids separated by commas"
    def list
      List.new(options).run
    end
  end
end
