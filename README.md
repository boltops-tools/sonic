# Sonic

Sonic is a multi-functional tool that helps you manage AWS resources. Sonic contains is a group of commands that help debug EC2 instance and ECS containers quickly.

## Why Sonic Was Created

After I exhaust debugging an ECS service with CloudWatch Logs I usually take it to the the next step: ssh into the instance. I jump into an instance with a running task or docker container and poke around to figure out the root issue.

In order to find the instance with the service's docker container I click around on the ECS console website until I find the container instance's DNS name and then paste it to the terminal. While this process is not complicated, it is tedious.  For example, the typical process is:

1. Click on the cluster
2. Click on the service
3. Click on the tasks tab
4. Click on the one of the tasks
5. Click on the container instance
6. Highlight and copy the DNS name
7. Paste the DNS name into the terminal to build up the ssh ec2-user@[dnsname] command
8. Ssh into the machine
9. Find the docker container with "docker ps"
10. Run docker exec -ti [container_id] bash
11. Finally, debug the actual problem

By the time I get into the container, I need to remind my brain on what the original issue was.  This tool automates that process so you do not waste your precious mental energy clicking on links and use it to focus on better things like fixing the **actual** issue.

## Install

### Install Via RubyGems

```
gem install sonic-ssh
```

Set up your AWS credentials at `~/.aws/credentials` and `~/.aws/config`.  This is the [AWS standard way of setting up credentials](https://aws.amazon.com/blogs/security/a-new-and-standardized-way-to-manage-credentials-in-the-aws-sdks/).

Note that the gem is named `sonic-ssh` but the command is `sonic`.

## Requirements

* [jq](https://stedolan.github.io/jq/manual/) - a lightweight and flexible command-line JSON processor

If you are also using the `ecs-exec` and `ecs-run` commands, then you will need to ensure that [jq](https://stedolan.github.io/jq/) is installed on all of your ECS container instances.  If you are only using the `sonic ssh` command then you do not need the jq dependency.

## Usage

### sonic ssh

To ssh into the host or container instance where an ECS service called `my-service` is running, simply run:

```
$ sonic ssh my-service --cluster my-cluster
# now you are on the container instance
$ docker ps
$ curl -s http://localhost:51678/v1/meta | jq .
```

The `my-service` can possible run on multiple container instances.  The `sonic` command chooses the first container instance that it finds.  If you need to ssh into a specific container instance, use `sonic ssh` instead.

You can also use the instance id, container instance arn or task arn to ssh into the machine.  Examples:

```
$ sonic ssh my-ecs-service --cluster my-cluster # cluster is required or ~/.sonic/settings.yml
$ sonic ssh i-067c5e3f026c1e801
$ sonic ssh 7fbc8c75-4675-4d39-a5a4-0395ff8cd474
$ sonic ssh 1ed12abd-645c-4a05-9acf-739b9d790170
```

### sonic ecs-exec

`sonic ecs-exec` will hop one more level and get you all the way into a live container for a service.  To quickly get yourself into a docker exec bash shell for a service:

```
$ sonic ecs-exec SERVICE bash
$ sonic ecs-exec SERVICE # same as above, defaults to bash shell
```

This ultimately runs the following command after it ssh into the container instance:

```
$ docker run -ti SERVICE_CONTAINER bash
```

Here are examples to show what is possible:

```
$ sonic ecs-exec my-service bash
# You're in the docker container now
$ ls # check out some files to make sure you're the right place
$ ps auxxx | grep puma # is the web process up?
$ env # are the environment variables properly set?
$ bundle exec rails c # start up a rails console to debug
```

You can also pass in bundle exec rails console if you want to get to that as quickly as possible.

```
$ sonic ecs-exec my-service 'bundle exec rails console'
# You're a rails console in the docker container now
> User.count
```

You must put commands with spaces in quotes.

You can also use the container instance id or instance id in place of the service name:

```
$ sonic ecs-exec 9f1dadc7-4f67-41da-abec-ec08810bfbc9 bash
$ i-006a097bb10643e20
```

### sonic ecs-run

The `sonic ecs-run` command is similar to the `sonic ecs-exec` command except it'll run a brand new container with the same environment variables as the task associated with the service. This allows you to debug in a container with the exact environment variables as the running tasks/containers without affecting the live service. So this is safer since you will not be able to mess up a live container that is in service.

This also allows you to run one off commands like a rake task. Here's an example:

```
sonic ecs-run my-service bundle exec 'rake do:something'
```

The default command opens up a bash shell.

```
sonic ecs-run my-service # start a bash shell
sonic ecs-run my-service bash # same thing
```

## Settings

A `~/.sonic/settings.yml` file is useful to adjust the behavior of sonic. One of the useful options is the `service_clsuter`.  This optoin maps services to clusters.  This saves you from  typing the `--cluster` option every time.  Here is an example `~/.sonic/settings.yml`:

```yaml
service_cluster:
  default: my-default-cluster
  hi-web-prod: prod
  hi-clock-prod: prod
  hi-worker-prod: prod
  hi-web-stag: stag
  hi-clock-stag: stag
  hi-worker-stag: stag
```

This results in shorter commands:

```
sonic ssh hi-web-prod
sonic ssh hi-clock-prod
sonic ssh hi-worker-stag
```

Instead of what you normally would have to type:

```
sonic ssh hi-web-prod --cluster prod
sonic ssh hi-clock-prod --cluster prod
sonic ssh hi-worker-stag --cluster stag
```

## Help and CLI Options

```
sonic help
sonic help ssh
sonic help ecs-exec
sonic help ecs-run
```

## Internals

If are interested in the internal logic to achieve what the sonic commands it is detailed on the [wiki](https://github.com/boltopslabs/sonic/wiki).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
