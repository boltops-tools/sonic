---
title: Quick Start
---

In a hurry? No sweat! Here's a quick overview of how to use sonic.

### Install

    gem install sonic-screwdriver

### Usage

    # ssh into an instance
    sonic ssh i-0f7f833131a51ce35
    sonic ssh demo-web # ec2 tag
    sonic ssh demo-web --cluster staging # ecs service name
    sonic ssh 7fbc8c75-4675-4d39-a5a4-0395ff8cd474 --cluster staging # ECS container id
    sonic ssh 1ed12abd-645c-4a05-9acf-739b9d790170 --cluster staging # ECS task id

    # docker exec to a running ECS docker container
    sonic ecs exec demo-web

    # docker run with same environment as the ECS docker running containers
    sonic ecs sh demo-web

    # run command on 1 instance
    sonic execute --instance-ids i-0f7f833131a51ce35 uptime

    # run command on all instances tagged with demo-web and worker
    sonic execute --tags Name=demo-web,demo-worker uptime

    # list ec2 instances
    sonic list demo-web

Congratulations! You now know the basic sonic screwdriver commands now.

Learn more in the next sections.

<a id="next" class="btn btn-primary" href="{% link docs.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

