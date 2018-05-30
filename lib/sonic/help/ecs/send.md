Ssh into an ECS container instance and runs a docker container using the same
environment and image as the specified running service.

Examples:

    $ sonic ecs send --cluster my-cluster my-service
    $ sonic ecs send --cluster my-cluster my-service

# If there are flags in the command that you want to pass down to the docker
run command you will need to put the command in single quotes.  This is due to
the way Thor (what this tool uses) parses options.

    $ sonic ecs send --cluster prod-hi hi-web-prod 'rake -T'
