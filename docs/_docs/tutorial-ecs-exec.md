---
title: ECS Exec
---

In the previous section we showed you how to use `sonic ssh` to quickly ssh into an instance.  Some of the identifiers used were ECS identifiers.  As you can see sonic is ECS smart.

One of the additional things `sonic` can do is hop one more level and get you all the way to the running docker container via `docker exec`.

It does this with a variety of scripts and trickery and is covered in [How It Works]({% link _docs/how-it-works.md %}).  Let's go through examples of how sonic can help you get into an running ECS docker container quickly.

### sonic ecs-exec

```sh
sonic ecs-exec [ECS_SERVICE] --cluster [ECS_CLUSTER]
```

Here's a concrete example:

```sh
sonic ecs-exec hi-web --cluster stag
```

You should see something like this:

```sh
$ sonic ecs-exec hi-web --cluster stag
Running: scp -r /tmp/sonic ec2-user@34.211.195.71:/tmp/sonic  > /dev/null
Warning: Permanently added '34.211.195.71' (ECDSA) to the list of known hosts.
=> ssh -t ec2-user@34.211.195.71 bash /tmp/sonic/bash_scripts/docker-exec.sh
Warning: Permanently added '34.211.195.71' (ECDSA) to the list of known hosts.
root@fc4035f90bdc:/app#
```

What you see in the last line above is a bash prompt because you are in a bash shell within the docker container!  Ultimately sonic runs runs a `docker exec -ti ECS_SERVICE_CONTAINER bash` after ssh-ing into the instance.  With one command you have placed yourself into the running container 🎉

### Possibilities

Here are examples to show what is possible:

```
$ sonic ecs-exec hi-web bash
# You're in the docker container now
$ ls # check out some files to make sure you're the right place
$ ps auxxx | grep puma # is the web process up?
$ env # are the environment variables properly set?
$ bundle exec rails c # start up a rails console to debug
```

You can also pass in bundle exec rails console if you want to get to that as quickly as possible.

```
$ sonic ecs-exec hi-web bundle exec rails console
# You're a rails console in the docker container now
> User.count
```

You can also use the container instance id or instance id in place of the service name:

```
sonic ecs-exec 9f1dadc7-4f67-41da-abec-ec08810bfbc9 bash
sonic ecs-exec i-006a097bb10643e20 bash
```

### Settings - service_cluster mapping

As mentioned in the [previous section]({% link _docs/tutorial-ssh.md %}) and also in the [Settings documentation]({% link _docs/settings.md %}) you can configure a `~/.sonic/settings.yml` file which shortens the command further.  Let's add this to your settings:

```yaml
service_cluster:
  default: stag
  hi-web: stag
```

This makes the command consise and memorable.

```sh
sonic ecs-exec hi-web
```

The rest of this section assumes that you have the `~/.sonic/settings.yml` set up.

You can also tack on a command at the end of the `ecs-exec` command to be run as a one off instead of starting a bash shell. Example:

```
$ sonic ecs-exec hi-web uname -a
Running: scp -r /tmp/sonic ec2-user@34.211.195.71:/tmp/sonic  > /dev/null
Warning: Permanently added '34.211.195.71' (ECDSA) to the list of known hosts.
=> ssh -t ec2-user@34.211.195.71 bash /tmp/sonic/bash_scripts/docker-exec.sh uname -a
Warning: Permanently added '34.211.195.71' (ECDSA) to the list of known hosts.
Linux fc4035f90bdc 4.4.51-40.58.amzn1.x86_64 #1 SMP Tue Feb 28 21:57:17 UTC 2017 x86_64 GNU/Linux
Connection to 34.211.195.71 closed.
$
```

Remember the command runs within the running docker container.

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial-ssh.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorial-ecs-run.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
