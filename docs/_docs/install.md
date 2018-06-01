---
title: Installation
---

### Install with RubyGems

If can install sonic via RubyGems:

```sh
gem install sonic-screwdriver
```

You can also add sonic to your Gemfile in your project if you are working with a ruby project.  It is not required for your project to be a ruby project to use sonic.

```ruby
gem "sonic-screwdriver"
```

### Install with Bolts Toolbelt

If you want to install sonic without having to worry about sonic's ruby dependency you can simply install the Bolts Toolbelt which has sonic included.

```sh
brew cask install boltopslabs/software/bolts
```

For more information about the Bolts Toolbelt or to get an installer for another operating system visit: [https://boltops.com/toolbelt](https://boltops.com/toolbelt)

### Server Side Dependencies

For a small set of the commands there are server side dependencies.

#### sonic ecs dependencies

For the `sonic ecs` commands to work `jq` is required on the server side. This is covered in the [How It Works]({% link _docs/how-it-works.md %}) section.

One way to install `jq` quickly is by using the `sonic execute` command.  For example:

```sh
sonic execute hi-web yum install -y jq
```

It is recommended that you install `jq` with the UserData script or bake it into the AMI though.

#### sonic execute dependencies

The `sonic execute` works alongside [Amazon EC2 Run Command](https://aws.amazon.com/ec2/execute/).  So it is required to be installed on the servers for `sonic execute` to work.

#### Amazon EC2 Run Manager Installation

Installing the EC2 Run Manager agent on your Linux servers is super simple and is only one command.

```sh
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
```

The full recommended instructions are on the official Amazon EC2 Systems Manager [Install SSM Agent](http://docs.aws.amazon.com/systems-manager/latest/userguide/ssm-agent.html) documentation.

The trickiest part of installing is likely making sure that the agent on the server has successfully checked into the SSM service.  Verify it by tailing `/var/log/amazon/ssm/errors/errors.log`.

If you are having issues, it is most likely IAM issues.  Amazon also provides [Configuring Security Roles](http://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-access.html) docs to fix any IAM issues.

You can verify the instances that have successfully checked into SSM with `aws ssm describe-instance-information`:

```sh
aws ssm describe-instance-information --output text --query "InstanceInformationList[*]"
```

Here's an example of the output:

```sh
$ aws ssm describe-instance-information --output text --query "InstanceInformationList[*]"
2.0.822.0 ip-10-10-41-38  10.10.41.38 i-030033c20c54bf149 True  1497482505.12 Online  Amazon Linux AMI  Linux 2017.03 EC2Instance
2.0.822.0 ip-10-10-110-135  10.10.110.135 i-0f7f833131a51ce35 True  1497482686.53 Online  Amazon Linux AMI  Linu2016.09 EC2Instance
$
```

More information is provided in the AWS Run Command Walkthrough [Using the AWS CLI](http://docs.aws.amazon.com/systems-manager/latest/userguide/walkthrough-cli.html).

<a id="prev" class="btn btn-basic" href="{% link docs.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/install-bastion.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

