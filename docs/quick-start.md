---
title: Quick Start
---

In a hurry? No sweat! Here's a quick overview of how to use sonic.

### Install

```sh
brew cask install boltopslabs/software/bolts
```

### Usage

```sh
# ssh into an instance
sonic ssh i-0f7f833131a51ce35

# docker exec to a running ECS docker container
sonic ecs-exec hi-web-stag

# docker run with same environment as the ECS docker running containers
sonic ecs-run hi-web-stag

# run command on 1 instance
sonic execute -f i-0f7f833131a51ce35 uptime

# run command on all instances tagged with hi-web-stag and worker
sonic execute -f hi-web-stag,hi-worker-stag uptime

# list ec2 instances
sonic list hi-web-stag
```

Congratulations! You now know the basics sonic screwdriver commands.

Learn more in the next sections.

<a id="next" class="btn btn-primary" href="{% link docs.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

