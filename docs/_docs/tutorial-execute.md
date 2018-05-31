---
title: Sonic Execute
---

### Run One Liners

Sonic provides a way to execute commands remotely and securely across a list of AWS servers.  It does this by leveraging [Amazon EC2 Run Command](https://aws.amazon.com/ec2/execute/).  Sonic hides any complexity and provides a simple interface for you.   The command is called `sonic execute`:

```sh
sonic execute [FILTER] [COMMAND]
```

Examples:

```sh
sonic execute hi-web uptime
sonic execute hi-web-prod uptime
sonic execute i-030033c20c54bf149,i-030033c20c54bf150 uname -a
sonic execute i-030033c20c54bf149 file://hello.sh
```

Let's do something more useful:

```sh
sonic execute hi-web yum install -y curl
```

The output of the command will show a useful `aws ssm list-commands` command to get status of the requested command.

```sh
$ sonic execute hi-web uptime
Command sent to AWS SSM. To check the details of the command:
aws ssm list-commands --command-id 4133e5eb-aa18-40dd-be25-a176eb15e515
Pro tip: the aws ssm command is already in your copy/paste clipboard.
$
```

The output of the commands ran are also showed in the EC2 Run Command Console.  Here's an example:

<img src="/img/tutorials/ec2-console-run-command.png" class="doc-photo" />

### Polymorphic Filter

The `sonic execute` command can understand a variety of different filters.  The filters can be a list of instances ids or one EC2 tag value.  Note, ECS service names are *not* supported for the filter.

Here is an example, where the uptime command will run on both i-030033c20c54bf149 and i-030033c20c54bf150 instances.

```sh
sonic execute i-066b140d9479e9681,i-09482b1a6e330fbf7 uptime
```

### Run Scripts

Sometimes you might want to run more than just a one-liner command. If you need to run a full script, you can provide the file path to the script by designating it with `file://`.  For example, here's a file called `hi.sh`:

```bash
#!/bin/bash
echo "hello world"
```

Here's how you run that file:

```sh
sonic execute hi-web file://hi.sh
```

The file gets read by `sonic execute` and sent to EC2 Run Command to be executed.

### Amazon EC2 Run Manager Installation

The `sonic execute` command relies on EC2 Run Manager. So you will need to have EC2 Run Manager installed on the servers where you want to the commands to be executed.

* You can follow the [installation guide]({% link _docs/install.md %}) to install EC2 Run Manager.
* You can read on [Why EC2 Run Manager]({% link _docs/why-ec2-run-command.md %}) is used also.

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial-ecs-run.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorial-list.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
