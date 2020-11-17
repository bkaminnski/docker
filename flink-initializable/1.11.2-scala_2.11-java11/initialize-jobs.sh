#!/bin/bash

set -e

if [ "x$INITIAL_JOBS" = "x" ]; then
  echo "No Flink jobs to initialize"
else
  sleep $INITIAL_JOBS_DELAY
  for INITIAL_JOB in $INITIAL_JOBS; do
    # INITIAL_JOB with pattern "MAIN_CLASS;JAR_FILE"
    JOB_VALUES=(${INITIAL_JOB//;/ })
    MAIN_CLASS=${JOB_VALUES[0]}
    JAR_FILE="$INITIAL_JOBS_DIR/${JOB_VALUES[1]}"

    echo "Trying to initialize $MAIN_CLASS in $JAR_FILE..."
    until flink run -d -m $INITIAL_JOBS_JOBMANAGER -c $MAIN_CLASS $JAR_FILE; do
      sleep $INITIAL_JOBS_PERIOD
      echo "Trying to initialize $MAIN_CLASS in $JAR_FILE..."
    done
  done
fi
