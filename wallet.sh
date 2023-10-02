#!/bin/bash
: ${CONTAINER_NAME:="bitbomb_bitbomb-1"}
docker exec -ti ${CONTAINER_NAME} simplewallet "$@"