#!/bin/bash -xe

TASK_ARN=$(cat /tmp/sonic/task-arn.txt)
CONTAINER_ID=$(curl -s http://localhost:51678/v1/tasks | jq ".Tasks[] | select(.Arn ==  \"$TASK_ARN\")" | jq -r '.Containers[].DockerId' | head -1)

# Got all the info in memory now we need os we can clean the files
rm -rf /tmp/sonic

if [ $1 ]; then
  COMMAND=$@
else
  COMMAND=bash
fi

exec docker exec -ti $CONTAINER_ID $COMMAND
