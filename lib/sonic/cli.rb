require 'thor'

module Sonic
  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean
    bastion_option = Proc.new {
      option :bastion, desc: "Bastion jump host to use.  Defaults to no bastion server."
    }
    cluster_option = Proc.new {
      option :cluster, desc: "ECS Cluster to use.  Default cluster is default"
    }

    desc "ssh [IDENTIFER]", "ssh into a instance using identifier. identifer can be several things: instance id, ec2 tag, ECS service name, etc"
    long_desc Help.text(:ssh)
    method_option :keys, :aliases => '-i', :desc => "comma separated list of ssh private key paths"
    method_option :retry, :aliases => '-r', :type => :boolean, :desc => "keep retrying the server login until successful. Useful when on newly launched instances."
    bastion_option.call
    def ssh(identifier, *command)
      Ssh.new(identifier, options.merge(command: command)).run
    end

    desc "ecs-exec [ECS_SERVICE]", "docker exec into running docker container associated with the service on a container instance"
    long_desc Help.text(:ecs_exec)
    bastion_option.call
    cluster_option.call
    def ecs_exec(service, *command)
      Docker.new(service, options.merge(command: command)).exec
    end

    # Cannot name the command run because that is a reserved Thor keyword :(
    desc "ecs-run [ECS_SERVICE]", "docker run with the service on a container instance"
    long_desc Help.text(:ecs_run)
    bastion_option.call
    cluster_option.call
    def ecs_run(service, *command)
      Docker.new(service, options.merge(command: command)).run
    end

    desc "run_command [FILTER] [COMMAND]", "runs command across fleet of servers via AWS Run Command"
    long_desc Help.text(:run_command)
    option :zero_warn, type: :boolean, default: true, desc: "Warns user when no instances found"
    # filter - Filter ec2 instances by tag name or instance_ids separated by commas
    def run_command(filter, *command)
      RunCommand.new(command, options.merge(filter: filter)).run_command
    end

    desc "list [FILTER]", "lists ec2 instances"
    long_desc Help.text(:list)
    option :header, type: :boolean, desc: "Displays header"
    # filter - Filter ec2 instances by tag name or instance_ids separated by commas
    def list(filter)
      List.new(options.merge(filter: filter)).run
    end
  end
end
