# Sonic Screwdriver

[![CircleCI](https://circleci.com/gh/boltopslabs/sonic.svg?style=svg)](https://circleci.com/gh/boltopslabs/sonic)
[![Gitter](https://badges.gitter.im/boltopslabs/sonic.svg)](https://gitter.im/boltopslabs/sonic?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Support](https://img.shields.io/badge/get-support-blue.svg)](https://boltops.com?utm_source=badge&utm_medium=badge&utm_campaign=sonic)

Sonic is a multi-functional tool that helps you manage AWS resources. Sonic contains is a group of commands that help debug EC2 instances and ECS containers quickly.

See [sonic-screwdriver.cloud](http://sonic-screwdriver.cloud) for full documentation.

## Why Sonic Was Created

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

## Install

If you want to quickly install sonic without having to worry about sonic's dependencies you can simply install the Bolts Toolbelt which has sonic included.

```sh
brew cask install boltopslabs/software/bolts
```

Or if you prefer you can install ufo with RubyGems

```sh
gem install ufo
```

Full installation instructions are at [Install Sonic Screwdriver](http://localhost:4000/docs/install/).  There are some server side dependencies for some of the sonic commands so it is important to read through the full installation guide.

## Quick Start

Here is a quick overview of sonic abilities:

```sh
# ssh into an instance
sonic ssh i-0f7f833131a51ce35
sonic ssh hi-web-stag # ec2 tag
sonic ssh hi-web-stag --cluster stag # ecs service name
sonic ssh hi-web-stag --cluster stag  # ecs service name
sonic ssh 7fbc8c75-4675-4d39-a5a4-0395ff8cd474 --cluster stag  # ECS container id
sonic ssh 1ed12abd-645c-4a05-9acf-739b9d790170 --cluster stag  # ECS task id

# docker exec to a running ECS docker container
sonic ecs-exec hi-web-stag

# docker run with same environment as the ECS docker running containers
sonic ecs-run hi-web-stag

# run command on 1 instance
sonic execute i-0f7f833131a51ce35 uptime

# run command on all instances tagged with hi-web-stag and worker
sonic execute hi-web-stag,hi-worker-stag uptime

# list ec2 instances
sonic list hi-web-stag
```

## Contributing

Everyone can contribute to make sonic-screwdriver better.  Please fork the project and open a pull request! We love your pull requests. Contributions are encouraged and welcomed!

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
