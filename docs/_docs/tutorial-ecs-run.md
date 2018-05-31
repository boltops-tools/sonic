---
title: ECS Run
---

The nice thing about the previous `ecs-exec` command we covered is that it allows you to get into the actual running container and debug with the exact environment that is on production.  The cavaet with doing this is that we are affecting a live process in actual use. If you do something inadvertently wrong on the server it could affect users.  Sometimes it is nice to start up a new container with the exact same environment as the other running containers but be isolated so you cannot affect live requests.

The `sonic ecs-run` command is similar to the `sonic ecs-exec` command except it'll run a brand new container with the same environment variables as the task associated with the service. This allows you to debug in a container with the exact environment variables as the running tasks/containers without affecting the live service. So this is safer since you will not be able to mess up a live container that is in service.

### sonic ecs-run

```sh
sonic ecs-run [ECS_SERVICE] --cluster [ECS_CLUSTER]
```

Here's an example:

```sh
sonic ecs-run hi-web
```

You see something like this:

```sh
$ sonic ecs-run hi-web
Running: scp -r /tmp/sonic ec2-user@34.211.195.71:/tmp/sonic  > /dev/null
Warning: Permanently added '34.211.195.71' (ECDSA) to the list of known hosts.
=> ssh -t ec2-user@34.211.195.71 bash /tmp/sonic/bash_scripts/docker-run.sh
Warning: Permanently added '34.211.195.71' (ECDSA) to the list of known hosts.
+ exec bundle exec rails server -b 0.0.0.0
=> Booting WEBrick
=> Rails 4.2.3 application starting in development on http://0.0.0.0:3000
=> Run `rails server -h` for more startup options
=> Ctrl-C to shutdown server
[2017-06-14 19:01:30] INFO  WEBrick 1.3.1
[2017-06-14 19:01:30] INFO  ruby 2.3.3 (2016-11-21) [x86_64-linux]
[2017-06-14 19:01:30] INFO  WEBrick::HTTPServer#start: pid=1 port=3000
^C[2017-06-14 19:01:34] INFO  going to shutdown ...
[2017-06-14 19:01:34] INFO  WEBrick::HTTPServer#start done.
Exiting
Connection to 34.211.195.71 closed.
$
```

In the above output a WEBrick server gets started.  The reason this happens is because the Dockerfile default `CMD` in this project happens to start a webserver.  Most of the time you probably want to start shell for debugging.  To start a bash shell just tack the bash command at the end.

```sh
$ sonic ecs-run hi-web bash
Running: scp -r /tmp/sonic ec2-user@34.211.195.71:/tmp/sonic  > /dev/null
Warning: Permanently added '34.211.195.71' (ECDSA) to the list of known hosts.
=> ssh -t ec2-user@34.211.195.71 bash /tmp/sonic/bash_scripts/docker-run.sh bash
Warning: Permanently added '34.211.195.71' (ECDSA) to the list of known hosts.
root@56a495dbd5cd:/app#
```

You are now in a docker container running exactly the same environment as the other running containers with the `hi-web` service. While this looks similiar to the `ecs-exec` command this container is a brand new process and is isolated from any live request. You can do whatever you want in this container and experiment to your heart's content.

We can prove that this is a brand new docker container that is outside of ECS' knowledge. Let's ssh into the same instance and take a look at all the running docker containers in another terminal.

```sh
$ sonic ssh hi-web docker ps
=> ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@34.211.195.71 docker ps
Warning: Permanently added '34.211.195.71' (ECDSA) to the list of known hosts.
CONTAINER ID        IMAGE                                          COMMAND             CREATED             STATUS              PORTS                     NAMES
29e7c1253c46        tongueroo/hi:ufo-2017-06-13T14-48-08-0a9eea5   "bash"              54 seconds ago      Up 53 seconds       3000/tcp                  cocky_goldstine
fc4035f90bdc        tongueroo/hi:ufo-2017-06-13T14-48-08-0a9eea5   "bin/web"           About an hour ago   Up About an hour    0.0.0.0:32768->3000/tcp   ecs-hi-web-11-web-9eb081978abad89a9701
bf646ae7789a        amazon/amazon-ecs-agent:latest                 "/agent"            About an hour ago   Up About an hour                              ecs-agent
$
```

The output shows that there is this extra runnning container called `cocky_goldstine`.  This name does not look like the typical ECS managed running docker container: `ecs-hi-web-11-web-9eb081978abad89a9701`.  This is how we know that this is a container outside of ECS control.

```sh
$ sonic ecs-run hi-web bash
Running: scp -r /tmp/sonic ec2-user@34.211.195.71:/tmp/sonic  > /dev/null
Warning: Permanently added '34.211.195.71' (ECDSA) to the list of known hosts.
=> ssh -t ec2-user@34.211.195.71 bash /tmp/sonic/bash_scripts/docker-run.sh bash
Warning: Permanently added '34.211.195.71' (ECDSA) to the list of known hosts.
root@29e7c1253c46:/app# exit
exit
Connection to 34.211.195.71 closed.
$
```

Let's exit out of the first terminal where you ran the original `sonic ecs-run` command and then list the running containers again.

```sh
$ sonic ssh hi-web docker ps
=> ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@34.211.195.71 docker ps
Warning: Permanently added '34.211.195.71' (ECDSA) to the list of known hosts.
CONTAINER ID        IMAGE                                          COMMAND             CREATED             STATUS              PORTS                     NAMES
fc4035f90bdc        tongueroo/hi:ufo-2017-06-13T14-48-08-0a9eea5   "bin/web"           About an hour ago   Up About an hour    0.0.0.0:32768->3000/tcp   ecs-hi-web-11-web-9eb081978abad89a9701
bf646ae7789a        amazon/amazon-ecs-agent:latest                 "/agent"            About an hour ago   Up About an hour                              ecs-agent
$
```

Zapped!  The `cocky_goldstine` container that was created with `sonic ecs-run` is no more.

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial-ecs-exec.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorial-execute.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
