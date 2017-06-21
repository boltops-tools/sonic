---
title: Why Sonic Was Created
---

After I exhaust debugging an ECS service with CloudWatch Logs I usually take it to the next step: ssh into the instance. I jump into an instance with a running task or docker container and poke around to figure out the root issue.

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

Sonic was created to eliminate mundane infrastructure debugging tasks we normally have to do.

<a id="prev" class="btn btn-basic" href="{% link _docs/help.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/why-ec2-run-command.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
