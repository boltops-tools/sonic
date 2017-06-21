require 'thor'
require 'sonic/cli/help'

module Sonic
  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean
    class_option :cluster, desc: "ECS Cluster to use.  Default cluster is default"
    class_option :bastion, desc: "Bastion jump host to use.  Defaults to no bastion server."
    class_option :project_root, desc: "Project root. Useful for testing.", hide: true

    stop_on_unknown_option! :ssh
    desc "ssh [IDENTIFER]", "ssh into a instance using identifier. identifer can be several things: instance id, ec2 tag, ECS service name, etc"
    long_desc Help.ssh
    def ssh(identifier, *command)
      Ssh.new(identifier, options.merge(command: command)).run
    end

    stop_on_unknown_option! :ecs_exec
    desc "ecs-exec [ECS_SERVICE]", "docker exec into running docker container associated with the service on a container instance"
    long_desc Help.ecs_exec
    def ecs_exec(service, *command)
      Docker.new(service, options.merge(command: command)).exec
    end

    # Cannot name the command run because that is a reserved Thor keyword :(
    stop_on_unknown_option! :ecs_run
    desc "ecs-run [ECS_SERVICE]", "docker run with the service on a container instance"
    long_desc Help.ecs_run
    def ecs_run(service, *command)
      Docker.new(service, options.merge(command: command)).run
    end

    stop_on_unknown_option! :execute
    desc "execute [FILTER] [COMMAND]", "runs command across fleet of servers via AWS Run Command"
    long_desc Help.execute
    # filter - Filter ec2 instances by tag name or instance_ids separated by commas
    def execute(filter, *command)
      Execute.new(command, options.merge(filter: filter)).execute
    end

    desc "list [FILTER]", "lists ec2 instances"
    long_desc Help.list
    option :header, type: :boolean, desc: "Displays header"
    # filter - Filter ec2 instances by tag name or instance_ids separated by commas
    def list(filter)
      List.new(options.merge(filter: filter)).run
    end
  end
end
