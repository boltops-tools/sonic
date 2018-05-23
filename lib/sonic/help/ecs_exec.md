Ssh into an ECS container instance, finds a running docker container associated
with the service and docker exec's into it.

Examples:

    $ sonic ecs_exec my-service --cluster my-cluster

You can use a variety of identifiers.  These include the ECS service name and task id.
