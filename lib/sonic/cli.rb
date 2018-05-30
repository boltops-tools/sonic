require 'thor'

module Sonic
  class CLI < BaseCommand
    desc "ecs SUBCOMMAND", "ecs subcommands"
    long_desc Help.text(:ecs)
    subcommand "ecs", Ecs

    desc "command SUBCOMMAND", "command subcommands"
    long_desc Help.text(:command)
    subcommand "command", Command

    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean
    desc "ssh [IDENTIFER]", "ssh into a instance using identifier. identifer can be several things: instance id, ec2 tag, ECS service name, etc"
    long_desc Help.text(:ssh)
    method_option :keys, :aliases => '-i', :desc => "comma separated list of ssh private key paths"
    method_option :retry, :aliases => '-r', :type => :boolean, :desc => "keep retrying the server login until successful. Useful when on newly launched instances."
    option :bastion, desc: "Bastion jump host to use.  Defaults to no bastion server."
    def ssh(identifier, *command)
      Ssh.new(identifier, options.merge(command: command)).run
    end

    desc "list [FILTER]", "lists ec2 instances"
    long_desc Help.text(:list)
    option :header, type: :boolean, desc: "Displays header"
    # filter - Filter ec2 instances by tag name or instance_ids separated by commas
    def list(filter)
      List.new(options.merge(filter: filter)).run
    end

    desc "completion *PARAMS", "Prints words for auto-completion."
    long_desc Help.text("completion")
    def completion(*params)
      Completer.new(CLI, *params).run
    end

    desc "completion_script", "Generates a script that can be eval to setup auto-completion."
    long_desc Help.text("completion_script")
    def completion_script
      Completer::Script.generate
    end

    desc "version", "prints version"
    def version
      puts VERSION
    end
  end
end
