---
title: Sonic Execute
---

### Run One Liners

Sonic provides a way to execute commands remotely and securely across a list of AWS servers.  It does this by leveraging [Amazon EC2 Run Command](https://aws.amazon.com/ec2/execute/).  Sonic a simple interface and some conveniences for you.   The command is called `sonic execute`:

    sonic execute [FILTER] [COMMAND]

## Examples Summary

    sonic execute --tags Name=demo-web uptime
    sonic execute --tags Name=demo-web,demo-worker uptime # multiple tag values
    sonic execute --instance-ids i-030033c20c54bf149,i-030033c20c54bf150 uname -a
    sonic execute --instance-ids i-030033c20c54bf149 file://hello.sh

## Example Detailed

Here's a command example output in detailed:

    $ sonic execute --instance-ids i-0bf51a000ab4e73a8 uptime
    Sending command to SSM with options:
    ---
    instance_ids:
    - i-0bf51a000ab4e73a8
    document_name: AWS-RunShellScript
    comment: sonic execute --instance-ids i-0bf51a000ab4e73a8 uptime
    parameters:
      commands:
      - uptime
    output_s3_region: us-east-1
    output_s3_bucket_name: [reacted]
    output_s3_key_prefix: ssm/commands/sonic

    Command sent to AWS SSM. To check the details of the command:
      aws ssm list-commands --command-id 0bb18d58-6436-49fd-9bfd-0c4b6c51c7a2
      aws ssm get-command-invocation --command-id 0bb18d58-6436-49fd-9bfd-0c4b6c51c7a2 --instance-id i-0bf51a000ab4e73a8

    Waiting for ssm command to finish.....
    Command finished.

    Displaying output for i-0bf51a000ab4e73a8.
    Command status: Success
    Command standard output:
     01:08:10 up 8 days,  6:41,  0 users,  load average: 0.00, 0.00, 0.00

    To see the more output details visit:
      https://us-west-2.console.aws.amazon.com/systems-manager/run-command/0bb18d58-6436-49fd-9bfd-0c4b6c51c7a2

    Pro tip: the console url is already in your copy/paste clipboard.
    $

Notice the conveniences of `sonic execute`, it:

1. Showed the parameters that will be sent as part of the send_command call to SSM.
2. Sent the command to SSM.
3. Waited for the command to finish.
4. Displayed the output of the command.
5. Provided the console url that visit to view more details about the SSM command.

The AWS SSM console looks like this:

<img src="/img/tutorials/ec2-console-run-command.png" class="doc-photo" />

### Filter Options

The `sonic execute` command can understand a variety of different filters: `--tags` and `--instance-ids`.  Note, ECS service names are *not* supported for the filter.

Here is an example, where the uptime command will run on both `i-030033c20c54bf149` and `i-030033c20c54bf150` instances.

    sonic execute --instance-ids i-066b140d9479e9681,i-09482b1a6e330fbf7 uptime

Here is an example, where the uptime command will run on instances tagged with `Name=demo-web`

    sonic execute --tags Name=demo-web uptime

## Windows Support

Windows is also supported. When running a command sonic will first attempt to use the `AWS-RunShellScript` run command, and if it detects that the instance's platform does not support `AWS-RunShellScript`, it will run the command with the `AWS-RunPowerShellScript` run command.  Here's an example:

```
$ sonic execute --instance-ids i-0917ad61b10fa1059 pwd
Sending command to SSM with options:
---
instance_ids:
- i-0917ad61b10fa1059
document_name: AWS-RunShellScript
comment: sonic execute --instance-ids i-0917ad61b10fa1059 pwd
parameters:
  commands:
  - pwd
output_s3_region: us-east-1
output_s3_bucket_name: boltops-infra-stag
output_s3_key_prefix: ssm/commands/sonic

Cannot perform operation for instance id i-0917ad61b10fa1059 of platform type Windows
Retrying with document_name AWS-RunPowerShellScript
Retries: 1
Command sent to AWS SSM. To check the details of the command:
  aws ssm list-commands --command-id 8a196058-445e-4960-9efb-be746ecf98dc
  aws ssm get-command-invocation --command-id 8a196058-445e-4960-9efb-be746ecf98dc --instance-id i-0917ad61b10fa1059

Waiting for ssm command to finish......
Command finished.

Displaying output for i-0917ad61b10fa1059.
Command status: Success
Command standard output:

Path
----
C:\Windows\system32



To see the more output details visit:
  https://us-east-1.console.aws.amazon.com/systems-manager/run-command/8a196058-445e-4960-9efb-be746ecf98dc

Pro tip: the console url is already in your copy/paste clipboard.
$
```

## Run Scripts

Sometimes you might want to run more than just a one-liner command. If you need to run a full script, you can provide the file path to the script by designating it with `file://`.  For example, here's a file called `hi.sh`:

    #!/bin/bash
    echo "hello world"

Here's how you run that file:

    sonic execute demo-web file://hi.sh

The file gets read by `sonic execute` and sent to EC2 Run Command to be executed.

### Amazon EC2 Run Manager Installation

The `sonic execute` command relies on EC2 Run Manager. So you will need to have EC2 Run Manager installed on the servers where you want to the commands to be executed.

* You can follow the [installation guide]({% link _docs/install.md %}) to install EC2 Run Manager.
* You can read on [Why EC2 Run Manager]({% link _docs/why-ec2-run-command.md %}) is used also.

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial-ecs-sh.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorial-list.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
