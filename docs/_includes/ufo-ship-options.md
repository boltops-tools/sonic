{:.ship-options}
Option  | Description
------------- | -------------
`--task`  | By convention sonic uses the same name for both the ECS service and task definition. You can override this convention with this option.  The conventions are covered on the [Conventions]({% link _docs/conventions.md %}) page.
`--target-group`  | The ELB target group to use for the ECS service. This is respected if the ECS service is being created the first time. If the ECS service already exists, this option gets ignored.
`--target-group-prompt`  | This boolean option allows you to bypass setting the ELB target group if desired.
`--docker`  | This boolean option determines whether to build the docker image first as part of the ship process.
`--tasks`  | This boolean option determines where to build and register the task definitions.
`--wait`  | This boolean option determines if sonic blocks and waits until the service has been deployed before continuing.
`--pretty`  | This boolean option determines sonic generates the task definitions in output in a pretty human readable format.
`--stop-old-tasks`  | This boolean option determines if sonic will call ecs stop-task on the old tasks after deployment. Sometimes old tasks hang around for a little bit with ECS this forces them along a little quicker.
`--ecr-keep`  | This integer option determines how many old docker images to keep around.  Ufo will automatically delete and clean up docker images at the end of this process. The default is reasonable large at 30.
`--cluster`  | This decides what cluster to use.  This can also be set in sonic/settings.yml covered in [Settings]({% link _docs/sonic-settings.md %}).  The cli option takes highest precedence.
