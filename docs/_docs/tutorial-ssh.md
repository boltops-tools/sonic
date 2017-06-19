---
title: SSH
---

### SSH

Sonic allows you to quickly ssh into an instance.

When working with AWS EC2 often times it is helpful ssh into the instance to debug.  In order to ssh into the instance the first thing you do is go to the EC2 Console and grab the public ip address.

<img src="/img/tutorials/ec2-console-public-ip.png" class="doc-photo" />

You use that ip address to build up an ssh command for accessing the instance.  Here's an example of the built up ssh command.

```sh
ssh ec2-user@52.24.216.170
```

You often have to go through this manual process of identifying the public ip address and building up the ssh command.

### Usage

Sonic will automatically build up the ssh command for you. Here's an example of the concise sonic ssh command.

```sh
sonic ssh i-027363802c6ff314f
```

The above command effectively translate to:

```sh
ssh ec2-user@52.24.216.170
```

By default the user that sonic uses to login to the server is `ec2-user`. This can easily be overriden at the CLI:

```sh
sonic ssh ubuntu@i-0f7f833131a51ce35
```

The user can also be configure with a `~/.sonic/settings.yml` or the project's `.sonic/settings.yml` file like so:

```yaml
user: ec2-user
```

The `sonic ssh` command can auto-detect the proper ip address with a variety of different identifiers; it is not just limited to the instance id. This is convenient if you happen to be on a dashboard with another identifer handy.  Here are examples of other identifiers that `sonic ssh` understands.

```
sonic ssh ECS_CONTAINER_ID --cluster stag
sonic ssh ECS_SERVICE --cluster stag
sonic ssh ECS_TASK_ID --cluster stag
```

Notice, that when the `sonic ssh` is passed an ECS identifier then it also requires the ECS cluster name. The commands above with the ECS identifier are normally shorten further by configuring the `~/.sonic/settings.yml` or the project's `.sonic/settings.yml` file.  Here's an example:

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

With these settings in place, the commands get shorten to become:

```sh
sonic ssh EC2_TAG_VALUE
sonic ssh ECS_CONTAINER_ID
sonic ssh ECS_SERVICE
sonic ssh ECS_TASK_ID
```

It becomes very easy to ssh into an EC2 Container Instance with the ECS service name.  For example if the ECS service name is `hi-web-stag`.

```sh
sonic ssh hi-web-stag
```

### Bastion Host

If you have an bastion host server which provides access to your internal servers then it is even more work to build up the ssh command.  The good news is that `sonic ssh` command also automates this!

Thus far we have assumed that the instances we are hopping into are publicly available on a public subnet and have an public ip address associate with it.  A common AWS setup is to have your servers on internal subnets without public addresses.  In this case we must first ssh into the bastion host and from there you can "jump" to the actually server.  This why the bastion host is also called a jump host.

You can configure the `settings.yml` file again to use a bastion host. Here's an example:

```yaml
bastion: bastion.mydomain.com
```

You run the `sonic ssh` command exactly the same way:

```
sonic ssh i-0f7f833131a51ce35
```

You should notice that the built up command now includes the bastion jump host.

```
$ sonic ssh i-0f7f833131a51ce35 uptime
=> ssh -At ec2-user@34.211.223.3 ssh ec2-user@10.10.110.135 uptime
Warning: Permanently added '34.211.223.3' (ECDSA) to the list of known hosts.
Warning: Permanently added '10.10.110.135' (ECDSA) to the list of known hosts.
 18:35:18 up  1:14,  0 users,  load average: 0.24, 0.07, 0.02
Connection to 34.211.223.3 closed.
$
```

Notice that the ssh command produced has the bastion jump host daisy chained in the command for you.

You can also specify the bastion host as a CLI option with `--bastion`, though it is recommended that you configure it in a `settings.yml` file so you don't have to type it repeatedly.

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorial-ecs-exec.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
