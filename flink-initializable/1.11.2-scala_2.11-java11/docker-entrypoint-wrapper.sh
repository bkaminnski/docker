#!/bin/bash

set -e

/initialize-jobs.sh &
/docker-entrypoint.sh $@
