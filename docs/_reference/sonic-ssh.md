---
title: sonic ssh
reference: true
---

## Usage

    sonic ssh [IDENTIFER]

## Description

ssh into a instance using identifier. identifer can be several things: instance id, ec2 tag, ECS service name, etc

Ssh quicky into an EC2 instance using an identifier. The identifier can be many things. Examples of valid identifiers:

* EC2 instance id. Example: i-067c5e3f026c1e801
* EC2 tag value. Any tag value is search, the tag key does not matter only the tag value matters. Example: hi-web-prod
* ECS service. Example: my-ecs-service
* ECS container instance id. Example: 7fbc8c75-4675-4d39-a5a4-0395ff8cd474
* ECS task id. Example: 1ed12abd-645c-4a05-9acf-739b9d790170

When using ecs identifiers the `--cluster` option is required or can be set in ~/.sonic/settings.yml.

Examples:

    $ sonic ssh i-067c5e3f026c1e801
    $ sonic ssh hi-web-prod
    $ sonic ssh --cluster my-cluster my-ecs-service
    $ sonic ssh 7fbc8c75-4675-4d39-a5a4-0395ff8cd474
    $ sonic ssh 1ed12abd-645c-4a05-9acf-739b9d790170

Sonic ssh builds up the ssh command and calls it. For example, the following commands:

    sonic ssh i-027363802c6ff314f

Translates to:

    ssh ec2-user@ec2-52-24-216-170.us-west-2.compute.amazonaws.com

You can also tack on any command to be run at the end of the command. Example:

    $ sonic ssh i-027363802c6ff314f uptime
    => ssh ec2-user@ec2-52-24-216-170.us-west-2.compute.amazonaws.com uptime
 15:57:02 up 18:21,  0 users,  load average: 0.00, 0.01, 0.00

Specifying pem keys:

The recommended way to specify custom private keys is to use ssh-agent as covered here: https://blog.boltops.com/2017/09/21/3-ssh-tips-ssh-agent-tunnel-and-escaping-from-the-dead

But you can also specify the pem key to use with the -i option.  Example:

    $ sonic ssh -i ~/.ssh/id_rsa-custom ec2-user@ec2-52-24-216-170.us-west-2.compute.amazonaws.com

Retry option:

For newly launched instances, the instance's ssh access might not be quite ready. Typically, you must press up enter repeatedly until the instance is ready.  Sonic ssh has a retry option that automates this. Example:

    $ sonic ssh -r i-027363802c6ff314f

Bastion Host Support

Sonic ssh also supports a bastion host.

    $ sonic ssh --bastion bastion.domain.com i-027363802c6ff314f
    $ sonic ssh --bastion user@bastion.domain.com i-027363802c6ff314f

Here's what the output looks like:

    $ sonic ssh --bastion 34.211.223.3 i-0f7f833131a51ce35 uptime
    => ssh -At ec2-user@34.211.223.3 ssh ec2-user@10.10.110.135 uptime
     17:57:59 up 37 min,  0 users,  load average: 0.00, 0.02, 0.00
    Connection to 34.211.223.3 closed.
    $


## Options

```
-i, [--keys=KEYS]                # comma separated list of ssh private key paths
-r, [--retry], [--no-retry]      # keep retrying the server login until successful. Useful when on newly launched instances.
    [--bastion=BASTION]          # Bastion jump host to use.  Defaults to no bastion server.
    [--verbose], [--no-verbose]  
    [--noop], [--no-noop]        
```

