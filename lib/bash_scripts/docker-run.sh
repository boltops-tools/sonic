#!/bin/bash -x

CONTAINER_IMAGE=$(cat /tmp/sonic/docker-image.txt)

# Got all the info in memory now we need os we can clean the files
# rm -rf /tmp/sonic
# Cannot remove files until we are done using the --env-file

# Maybe do this later.  But will need to have sonic path be unique.
# at -f "/tmp/sonic/seppuku.sh" now + 1.minute

cp /tmp/sonic/env-file.txt ~/
rm -rf /tmp/sonic

exec docker run -ti --env-file ~/env-file.txt $CONTAINER_IMAGE "$@"
