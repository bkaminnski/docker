#!/bin/bash

set -e

/opt/mssql/bin/sqlservr &
MSSQL_PID=$!
/wait-for-mssql.sh

INIT_DATABASES_FILE=/tmp/init_databases.sql

# Generate and run init cli only if it does not exist yet
if [[ ! -f "$INIT_DATABASES_FILE" ]]; then
	touch $INIT_DATABASES_FILE
	for INITIAL_DATABASE in $INITIAL_DATABASES; do
		echo "CREATE DATABASE $INITIAL_DATABASE;" >> $INIT_DATABASES_FILE
		echo "GO" >> $INIT_DATABASES_FILE
		echo "ALTER DATABASE $INITIAL_DATABASE SET READ_COMMITTED_SNAPSHOT ON;" >> $INIT_DATABASES_FILE
		echo "GO" >> $INIT_DATABASES_FILE
	done
	cat $INIT_DATABASES_FILE
	/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d master -i $INIT_DATABASES_FILE
fi

/wait-for-mssql-dbs.sh

wait $MSSQL_PID