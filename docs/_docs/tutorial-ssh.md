---
title: SSH
---

### SSH

Sonic allows you to quickly ssh into an instance.

Often times when working with AWS EC2 it is helpful to ssh into an instance to debug.  In order to ssh into an instance the first thing you do is go to the EC2 Console and grab the public ip address.

<img src="/img/tutorials/ec2-console-public-ip.png" class="doc-photo" />

You use that ip address to build up an ssh command for accessing the instance.  Here's an example of the built up ssh command.

```sh
ssh ec2-user@52.24.216.170
```

You often have to go through this manual process of identifying the public ip address and building up the ssh command repeatedly.

### Usage

Sonic automatically builds up the ssh command for you. Here's an example of the sonic ssh command.

```sh
sonic ssh i-027363802c6ff314f
```

The above command effectively translate to:

```sh
ssh ec2-user@52.24.216.170
```

By default the user that sonic uses to login to the server is `ec2-user`. This can easily be overriden:

```sh
sonic ssh ubuntu@i-0f7f833131a51ce35
```

The default user can also be configure with a `~/.sonic/settings.yml` or the project's `.sonic/settings.yml` file like so:

```yaml
user: ec2-user
```

More information about sonic settings in available in the docs: [Settings]({% link _docs/settings.md %}).

### Different Identifiers

The `sonic ssh` command can auto-detect the proper ip address with a variety of different identifiers.  It is not just limited to the instance id. This is convenient in case you happen to be on a dashboard with another identifer close by and handy.  Here are examples of other identifiers that `sonic ssh` understands.

```
sonic ssh EC2_TAG_FILTER
sonic ssh ECS_CONTAINER_ID --cluster stag
sonic ssh ECS_SERVICE --cluster stag
sonic ssh ECS_TASK_ID --cluster stag
```

Notice, that when the `sonic ssh` is passed an ECS identifier then it also requires the ECS cluster name. The commands above with the ECS identifier are normally shorten further by configuring the a [settings]({% link _docs/settings.md %}) file.  Here's an example:

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

With these settings in place, the ECS identifier commands get shorten to become:

```sh
sonic ssh ECS_CONTAINER_ID
sonic ssh ECS_SERVICE
sonic ssh ECS_TASK_ID
```

It then becomes very easy to ssh into an EC2 Container Instance with the ECS service name.  For example if the ECS service name is `hi-web-stag` then the command becomes.

```sh
$ sonic ssh hi-web-stag
# now you are on the container instance
$ docker ps
$ curl -s http://localhost:51678/v1/meta | jq .
```

The `hi-web-stag` can possibly be running on multiple container instances.  The `sonic` command chooses the first container instance that it finds.  If you need to ssh into a specific container instance, use `sonic ssh` instead.

You can also use the ECS container instance arn or task id to ssh into the machine.  Examples:

```
$ sonic ssh 7fbc8c75-4675-4d39-a5a4-0395ff8cd474 # ECS container id
$ sonic ssh 1ed12abd-645c-4a05-9acf-739b9d790170 # ECS task id
```

### Bastion Host

Thus far we have assumed that the instances we are hopping into are publicly available on a public subnet and have an public ip address associate with it.  A common AWS setup is to have your servers on internal subnets without public addresses.  In this case we must first ssh into the bastion host and from there we can "jump" into the actually server.  This why the bastion host is also called a jump host.

If you have an bastion host server which provides access to your internal servers then it is even more work to build up the ssh command.  The good news is that the `sonic ssh` command supports bastion hosts and automates this process! The [Bastion Setup]({% link _docs/install-bastion.md %}) doc covers how to set this up.


<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorial-ecs-exec.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
