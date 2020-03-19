#!/bin/bash

set -e

until /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -q 'exit'; do
  sleep 1
done

echo "#################################### SQL Server started"