---
title: Sonic Execute
---

Sonic provides a way to execute commands remotely and securely across a list of AWS servers.  It does this by relying on [Amazon EC2 Run Command](https://aws.amazon.com/ec2/execute/).  Sonic hides any complexity and provides a simplier interface for you. Example:

```sh
sonic execute --filter hi-web-stag "uptime"
```

Let's do something more useful:

```sh
sonic execute --filter hi-web-stag "yum install -y curl"
```

The output of the commands ran are showed in the EC2 Run Command Console.  Here's an example:

```
$ sonic execute --filter hi-web-stag uptime
Command sent to AWS SSM. To check the details of the command:
aws ssm list-commands --command-id 4133e5eb-aa18-40dd-be25-a176eb15e515
Pro tip: the aws ssm command is already in your copy/paste clipboard.
$
```

### Why Amazon EC2 Run Command

Why use Amazon EC2 Run Command vs just using a multi-ssh session?

* Some times it is not possible to use ssh across several servers.  For example, really secured networks might have [MFA setup](TODO) so you need to authorized the requests via your phone before the command actually gets ran. In this case, you would get annoying confirmation notifications on your phone over and over as you approve each request for each of your servers.
* EC2 Run Command provides auditability. Any command that runs the EC2 Run Command gets logged and is tracked.
* The EC2 Run Manager has the ability to run the command in "blue/green" fashion with concurrency controls. Say you have 100 servers, you can tell EC2 Run Manager to run the command on one server first and the expodentially roll it out to the rest of the servers until the command has successfully ran on all servers.  If it the command errors then it execute can be told to halt.
* This is all provided for free by using EC2 Run Manager.

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial-ecs-run.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/settings.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
