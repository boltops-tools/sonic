---
title: sonic ecs sh
reference: true
---

## Usage

    sonic ecs sh [ECS_SERVICE]

## Description

docker run with the service on a container instance

Ssh into an ECS container instance and runs a docker container using the same
environment and image as the specified running service.

Examples:

    $ sonic ecs sh --cluster my-cluster my-service
    $ sonic ecs sh --cluster my-cluster my-service

# If there are flags in the command that you want to pass down to the docker
run command you will need to put the command in single quotes.  This is due to
the way Thor (what this tool uses) parses options.

    $ sonic ecs sh --cluster production-hi hi-web 'rake -T'


## Options

```
[--bastion=BASTION]  # Bastion jump host to use.  Defaults to no bastion server.
[--cluster=CLUSTER]  # ECS Cluster to use.  Default cluster is default
```

