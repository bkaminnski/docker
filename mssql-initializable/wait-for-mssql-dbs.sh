#!/bin/bash

set -e

echo "#################################### INITIAL_DATABASES $INITIAL_DATABASES"

if [ "x$INITIAL_DATABASES" = "x" ]; then
  until /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -q 'exit'; do
    sleep 1
  done
else
  for INITIAL_DATABASE in $INITIAL_DATABASES; do
    until /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d $INITIAL_DATABASE -q 'exit'; do
      sleep 1
    done
  done
fi

echo "#################################### All databases created/started"
