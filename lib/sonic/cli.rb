require 'thor'
require 'sonic/cli/help'

module Sonic
  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean
    class_option :cluster, desc: "ECS Cluster to use.  Default cluster is default"

    desc "ssh IDENTIFER", "ssh into a instance using identifier. identifer can be be service name or instance id"
    long_desc Help.ssh
    def ssh(service, *command)
      Ssh.new(service, options.merge(command: command)).run
    end

    desc "ecs-exec SERVICE", "docker exec into running docker container associated with the service on a container instance"
    long_desc Help.ecs_exec
    def ecs_exec(service, *command)
      Docker.new(service, options.merge(command: command)).exec
    end

    # Cannot name the command run because that is a reserved Thor keyword :(
    desc "ecs-run SERVICE", "docker run with the service on a container instance"
    long_desc Help.ecs_run
    def ecs_run(service, *command)
      Docker.new(service, options.merge(command: command)).run
    end
  end
end
