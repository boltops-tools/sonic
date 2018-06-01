---
title: sonic ecs exec
reference: true
---

## Usage

    sonic ecs exec [ECS_SERVICE]

## Description

docker exec into running docker container associated with the service on a container instance

Ssh into an ECS container instance, finds a running docker container associated
with the service and docker exec's into it.

Examples:

    $ sonic ecs exec my-service --cluster my-cluster

You can use a variety of identifiers.  These include the ECS service name and task id.


## Options

```
[--bastion=BASTION]  # Bastion jump host to use.  Defaults to no bastion server.
[--cluster=CLUSTER]  # ECS Cluster to use.  Default cluster is default
```

