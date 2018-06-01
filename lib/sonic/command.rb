module Sonic
  class Command < BaseCommand
    desc "send [FILTER] [COMMAND]", "runs command across fleet of servers via AWS Run Command"
    long_desc Help.text("command/send")
    option :zero_warn, type: :boolean, default: true, desc: "Warns user when no instances found"
    # filter - Filter ec2 instances by tag name or instance_ids separated by commas
    def send(filter, *command)
      Commander.new(command, options.merge(filter: filter)).execute
    end
  end
end
