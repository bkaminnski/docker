#!/bin/bash

set -e

if [ "x$INITIAL_JOBS" = "x" ]; then
  echo "No Flink jobs to initialize"
else
  sleep $INITIAL_JOBS_DELAY
  IFS=$'\n'
  for INITIAL_JOB in $INITIAL_JOBS; do
    # INITIAL_JOB with pattern "MAIN_CLASS;JAR_FILE;EXPECTED_STATUS"
    JOB_VALUES=(${INITIAL_JOB//;/$'\n'})
    MAIN_CLASS=${JOB_VALUES[0]}
    JAR_FILE="$INITIAL_JOBS_DIR/${JOB_VALUES[1]}"
    EXPECTED_STATUS=${JOB_VALUES[2]}
    
    echo "########## Trying to initialize $MAIN_CLASS in $JAR_FILE, waiting for \"$EXPECTED_STATUS\"..."
    until flink list -r -m $INITIAL_JOBS_JOBMANAGER | grep $EXPECTED_STATUS; do
      flink run -d -m $INITIAL_JOBS_JOBMANAGER -c $MAIN_CLASS $JAR_FILE
      sleep $INITIAL_JOBS_PERIOD
      echo "########## Trying to initialize $MAIN_CLASS in $JAR_FILE, waiting for \"$EXPECTED_STATUS\"..."
    done
  done
fi
