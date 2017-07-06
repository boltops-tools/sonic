---
title: Docs
---

### Overview

Sonic Screwdriver is a multi-functional tool to manage AWS infrastructure.  It contains a variety of commands to make your job easier. It's main focus is to automate mundane repetitive tasks into simple one line commmands. With it you are to able debug environments and issues quickly.

The actually command that Sonic Screwdriver provides is called `sonic`.  Here's a list of things that `sonic` can do:

* Quickly ssh into an instance using convenient identifiers like instance id, container instance id, ecs service names, etc. It can do this even if there is a bastion host.
* Quickly jump all the way into the instance and grab the docker name and run `docker exec -ti` on it.
* Quickly jump all the way into the instance and run `docker run` with the same environment as current running docker containers.
* Quickly execute across a set of servers.

Next we'll cover different ways to install the Sonic Screwdriver.

<a id="prev" class="btn btn-basic" href="{% link quick-start.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/install.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

