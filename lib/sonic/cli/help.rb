# https://github.com/erikhuda/thor/issues/398
class Thor
  module Shell
    class Basic
      def print_wrapped(message, options = {})
        pretty_message = message.split("\n").map{|l| "  #{l}"}.join("\n")
        stdout.puts pretty_message
      end
    end
  end
end

module Sonic
  class CLI < Command
    class Help
      class << self
        def ssh
<<-EOL
Ssh quicky into an EC2 instance using an identifier. The identifier can be many
different things:

* EC2 instance id. Example: i-067c5e3f026c1e801
* ECS service. Example: my-ecs-service
* ECS container instance id. Example: 7fbc8c75-4675-4d39-a5a4-0395ff8cd474
* ECS task id. Example: 1ed12abd-645c-4a05-9acf-739b9d790170

Examples:

$ sonic ssh my-ecs-service --cluster my-cluster # cluster is required or ~/.sonic/settings.yml
$ sonic ssh i-067c5e3f026c1e801
$ sonic ssh 7fbc8c75-4675-4d39-a5a4-0395ff8cd474
$ sonic ssh 1ed12abd-645c-4a05-9acf-739b9d790170
EOL
        end

        def ecs_exec
<<-EOL
Ssh into an ECS container instance, finds a running docker container associated
with the service and docker exec's into it.

Examples:

$ sonic ecs-exec my-service --cluster my-cluster
EOL
        end

        def ecs_run
<<-EOL
Ssh into an ECS container instance and runs a docker container using the same
environment and image as the specified running service.

Examples:

$ sonic ecs-run my-service --cluster my-cluster
$ sonic ecs-run my-service --cluster my-cluster

# If there are flags in the command that you want to pass down to the docker
run command you will need to put the command in single quotes.  This is due to
the way Thor (what this tool uses) parses options.

$ sonic ecs-run --cluster prod-hi hi-web-prod 'rake -T'
EOL
        end
      end
    end
  end
end
