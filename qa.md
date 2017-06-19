# QA Notes

sonic ssh [INSTANCE_ID]
* when instance is ready
* when instance is terminated
* when instance is pending
* when instance does not exist

sonic ssh [ECS_CONTAINER_ID]
* when container instance found
* when container instance is terminated
* when container instance does not exist

sonic ssh [ECS_SERVICE]
* when service found and instance found
* when service found but instance not found
* when service not found

sonic ssh [ECS_TASK_ID]
* when task found and instance found
* when task not found
