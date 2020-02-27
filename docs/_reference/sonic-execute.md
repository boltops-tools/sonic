---
title: sonic execute
reference: true
---

## Usage

    sonic execute [FILTER] [COMMAND]

## Description

Runs command across fleet of servers via AWS Run Command.

* A filter must be provided.  The filter can be a mix of instance ids and ec2 tags.
* The command can be provided inline or as a file. To a file use `file://` at the beginning of your file.

## Examples Summary

    sonic execute --tags Name=demo-web uptime
    sonic execute --tags Name=demo-web,demo-worker uptime # multiple values
    sonic execute --instance-ids i-030033c20c54bf149,i-030033c20c54bf150 uname -a
    sonic execute --instance-ids i-030033c20c54bf149 file://hello.sh # script from file

You cannot mix instance ids and tag names in the filter.

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


## Options

```
[--zero-warn], [--no-zero-warn]  # Warns user when no instances found
                                 # Default: true
[--instance-ids=INSTANCE_IDS]    # Instance ids to execute command on. Format: --instance-ids "i-111,i-222"
[--tags=TAGS]                    # Tags used to determine what instances to execute command on. Format: --tags "Key1=v1,v2;Key2=v3"
[--verbose], [--no-verbose]      
[--noop], [--no-noop]            
```

