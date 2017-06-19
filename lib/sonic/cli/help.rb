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
Ssh quicky into an EC2 instance using an identifier. The identifier can be many things. Examples of valid identifiers:

* EC2 instance id. Example: i-067c5e3f026c1e801
* EC2 tag value. Any tag value is search, the tag key does not matter only the tag value matters. Example: hi-web-prod
* ECS service. Example: my-ecs-service
* ECS container instance id. Example: 7fbc8c75-4675-4d39-a5a4-0395ff8cd474
* ECS task id. Example: 1ed12abd-645c-4a05-9acf-739b9d790170

Examples:

$ sonic ssh i-067c5e3f026c1e801
$ sonic ssh hi-web-prod
$ sonic ssh my-ecs-service --cluster my-cluster # cluster is required or ~/.sonic/settings.yml
$ sonic ssh 7fbc8c75-4675-4d39-a5a4-0395ff8cd474
$ sonic ssh 1ed12abd-645c-4a05-9acf-739b9d790170

Sonic ssh builds up the ssh command and calls it. For example, the following commands:

sonic ssh i-027363802c6ff314f

Translates to:

ssh ec2-user@ec2-52-24-216-170.us-west-2.compute.amazonaws.com

You can also tack on any command to be run at the end of the command. Example:

$ sonic ssh i-027363802c6ff314f uptime
=> ssh ec2-user@ec2-52-24-216-170.us-west-2.compute.amazonaws.com uptime
 15:57:02 up 18:21,  0 users,  load average: 0.00, 0.01, 0.00

Bastion Host Support

Sonic ssh also supports a bastion host.

$ sonic ssh i-027363802c6ff314f --bastion bastion.domain.com
$ sonic ssh i-027363802c6ff314f --bastion user@bastion.domain.com

Here's what the output looks like:

$ sonic ssh i-0f7f833131a51ce35 --bastion 34.211.223.3 uptime
=> ssh -At ec2-user@34.211.223.3 ssh ec2-user@10.10.110.135 uptime
 17:57:59 up 37 min,  0 users,  load average: 0.00, 0.02, 0.00
Connection to 34.211.223.3 closed.
$
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

        def execute
<<-EOL
Run as a command across a list of servers. A filter must be provided.  The filter can be a mix of instance ids and ec2 tags. sonic execute will auto-detect the what type of filter it is and send it properly to EC2 Run Command.

Examples:

$ sonic execute --filter hi-web-prod uptime
$ sonic execute --filter hi-web-prod,hi-worker-prod,hi-clock-prod uptime
$ sonic execute --filter i-030033c20c54bf149,i-030033c20c54bf150 uname -a

You cannot mix instance ids and tag names in the filter.
EOL
        end

        def list
<<-EOL
List ec2 servers. A filter must be provided.  The filter can be a mix of instance ids and ec2 tags. sonic list will auto-detect the what type of filter it is filter appropriately.  The filter for listing is optional.

Examples:

$ sonic list
$ sonic list --filter hi-web-prod
$ sonic list --filter hi-web-prod,hi-clock-prod
$ sonic list --filter i-09482b1a6e330fbf7

Example Output:

$ sonic list --filter i-09482b1a6e330fbf7 --header
Instance Id Public IP Private IP  Type
i-09482b1a6e330fbf7 54.202.152.168  172.31.21.108 t2.small
$

You cannot mix instance ids and tag names in the filter.
EOL
        end
      end
    end
  end
end
