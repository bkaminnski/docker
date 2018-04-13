#!/bin/bash

set -e

if [ "x$INITIAL_DATABASES" = "x"]; then
  until psql -h "localhost" -U "postgres" -c '\q'; do
    sleep 1
  done
else
  for INITIAL_DATABASE in $INITIAL_DATABASES; do
    # INITIAL_DATABASE with pattern "SERVICE_NAME;PASSWORD"
    DATABASE_VALUES=(${INITIAL_DATABASE//;/ })
    SERVICE_NAME=${DATABASE_VALUES[0]}
    PGPASSWORD=${DATABASE_VALUES[1]}
    
    DB_USER=$SERVICE_NAME
    DB_NAME=$SERVICE_NAME
    
    until psql -h "localhost" -U "$DB_USER" -d "$DB_NAME" -c "select 1"; do
      sleep 1
    done
  done
fi

echo "READY" > /state

