---
title: ECS Run
---

The nice thing about the previous `ecs exec` command we covered is that it allows you to get into the actual running container and debug with the exact environment that is on production.  The cavaet with doing this is that we are affecting a live process that could be in actual use. If you do something inadvertently wrong on the server it could affect users.  Sometimes it is nice to start up a new container with the exact same environment as the other running containers but be isolated so you cannot affect live requests.

The `sonic ecs sh` command is similar to the `sonic ecs exec` command except it'll run a brand new container with the same environment variables as the task associated with the service. This allows you to debug in a container with the exact environment variables as the running tasks/containers without affecting the live service. So this is safer since you will not be able to mess up a live container that is in service.

### sonic ecs sh

```sh
sonic ecs sh [ECS_SERVICE] --cluster [ECS_CLUSTER]
```

Here's an example:

```sh
sonic ecs sh hi-web
```

You see something like this:

```sh
$ sonic ecs sh hi-web
Running: scp -r /tmp/sonic ec2-user@34.211.195.71:/tmp/sonic  > /dev/null
=> ssh -t ec2-user@34.211.195.71 bash /tmp/sonic/bash_scripts/docker-run.sh
+ exec docker exec -ti 385b643c7a895231d2b193574368b0c6c6bebce487267c3c175d0acea3082d4c bash
root@29e7c1253c46:/app#
$
```

You are now in a docker container running exactly the same environment as the other running containers with the `hi-web` service. While this looks similiar to the `ecs exec` command this container is a brand new process and is isolated from any live request. You can do whatever you want in this container and experiment to your heart's content.

We can prove that this is a brand new docker container that is outside of ECS' knowledge. Let's ssh into the same instance and take a look at all the running docker containers in another terminal.

```sh
$ sonic ssh hi-web docker ps
=> ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@34.211.195.71 docker ps
CONTAINER ID        IMAGE                                          COMMAND             CREATED             STATUS              PORTS                     NAMES
29e7c1253c46        tongueroo/hi:ufo-2017-06-13T14-48-08-0a9eea5   "bash"              54 seconds ago      Up 53 seconds       3000/tcp                  cocky_goldstine
fc4035f90bdc        tongueroo/hi:ufo-2017-06-13T14-48-08-0a9eea5   "bin/web"           About an hour ago   Up About an hour    0.0.0.0:32768->3000/tcp   ecs-hi-web-11-web-9eb081978abad89a9701
bf646ae7789a        amazon/amazon-ecs-agent:latest                 "/agent"            About an hour ago   Up About an hour                              ecs-agent
$
```

The output shows that there is this extra runnning container called `cocky_goldstine`.  This name does not look like the typical ECS managed running docker container: `ecs-hi-web-11-web-9eb081978abad89a9701`.  This is how we can tell that this is a container outside of ECS control.

```sh
$ sonic ecs sh hi-web bash
Running: scp -r /tmp/sonic ec2-user@34.211.195.71:/tmp/sonic  > /dev/null
=> ssh -t ec2-user@34.211.195.71 bash /tmp/sonic/bash_scripts/docker-run.sh bash
root@29e7c1253c46:/app# exit
exit
Connection to 34.211.195.71 closed.
$
```

Let's exit out of the first terminal where you ran the original `sonic ecs sh` command and then list the running containers again.

```sh
$ sonic ssh hi-web docker ps
=> ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@34.211.195.71 docker ps
CONTAINER ID        IMAGE                                          COMMAND             CREATED             STATUS              PORTS                     NAMES
fc4035f90bdc        tongueroo/hi:ufo-2017-06-13T14-48-08-0a9eea5   "bin/web"           About an hour ago   Up About an hour    0.0.0.0:32768->3000/tcp   ecs-hi-web-11-web-9eb081978abad89a9701
bf646ae7789a        amazon/amazon-ecs-agent:latest                 "/agent"            About an hour ago   Up About an hour                              ecs-agent
$
```

Zapped!  The `cocky_goldstine` container that was created with `sonic ecs sh` is no more.

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial-ecs-exec.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorial-execute.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
