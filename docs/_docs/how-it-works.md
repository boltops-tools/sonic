---
title: How It Works
---

### Internals

The process that I outline in the [Why]({% link _docs/why.md %}) about clicking around is close to the logic that actually takes place in the tool but it is actually slightly different. Here's an overview of what actually happens internally for those who are interested.

Steps:

1. list-tasks: list all the tasks for their task_arns (scoped to service).  this is all tasks on the service.  We already know the service name!
2. describe-tasks: Using the task_arns from list-tasks. This will provide the container instance scoped the service since list-tasks was scoped to service.  Keep the task arn for step 7. Also describe-task-definition and capture env vars and image for step 8b.
3. describe-container-instances: Using container\_instance\_arn from step 2. This will provide the instance_id to ssh into.
4. ec2 describe-instances to get the dns name or IP address.
5. Copy over files with required info over to the server with scp.
6. ssh into the machine with IP address.
7. Use the ecs metadata and pass it the task_arn from step 2. This will provide the map to the container id.
8. Run docker command
    1. docker exec -ti CONTAINER_ID `options[:command]`
    2. docker run `options[:run_options]` IMAGE `options[:command]`

In order to pass info over from your local machine to the container instance a file is generated and copied in step 5. File contains:

* Options all the way from the original cli call like command to run. This is in json form.
A bash script is also copied.
* Bash script gets the container id using the task_arn. It also will run the docker exec or run command.
* So bash script does steps 7 and 8.1 or 8.2.

NOTE: I thought it would be possible to map the container instance info from `aws ecs describe-services` but it is not possible. But we can map to the container instance DNS name starting from `aws ecs list-tasks`.


<a id="prev" class="btn btn-basic" href="{% link _docs/why.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/next-steps.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
