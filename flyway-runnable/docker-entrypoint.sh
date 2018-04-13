#!/bin/bash

set -e

/state-service.sh &
STATE_SERVICE_PID=$!

if  [ "x" != "x$WAIT_FOR" ] && { [ "$1" = 'infoAll' ] || [ "$1" = 'migrateAll' ]; }; then
	for WAITING in $WAIT_FOR; do
		# WAITING with pattern "HOST:PORT:EXPECTED_STRING"
		WAITING_VALUES=(${WAITING//;/ })
		HOST=${WAITING_VALUES[0]}
		PORT=${WAITING_VALUES[1]}
		EXPECTED=${WAITING_VALUES[2]}
		
		until netcat $HOST $PORT | grep $EXPECTED; do
			echo "Waiting for $HOST:$PORT to respond with $EXPECTED"
			sleep 1
		done
	done
fi

INFO_ALL_FILE=/flyway/infoAll.sh
MIGRATE_ALL_FILE=/flyway/migrateAll.sh

# Generate and run init cli only if it does not exist yet
if [[ ! -f "$MIGRATE_ALL_FILE" ]]; then
	echo '#!/bin/bash' > $INFO_ALL_FILE
	echo '#!/bin/bash' > $MIGRATE_ALL_FILE
	echo 'set -e' >> $INFO_ALL_FILE
	echo 'set -e' >> $MIGRATE_ALL_FILE
	for DATABASE in $DATABASES; do
		# DATABASE with pattern "SERVICE_NAME;DB_HOST;DB_PORT;DB_PASSWORD"
		DATABASE_VALUES=(${DATABASE//;/ })
		SERVICE_NAME=${DATABASE_VALUES[0]}
		DB_HOST=${DATABASE_VALUES[1]}
		DB_PORT=${DATABASE_VALUES[2]}
		DB_PASSWORD=${DATABASE_VALUES[3]}
		
		DB_NAME=$SERVICE_NAME
		DB_USER=$SERVICE_NAME
		
		echo "/flyway/flyway -locations=filesystem:/flyway/databases/$DB_NAME -url=jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME -user=$DB_USER -password=$DB_PASSWORD info" >> $INFO_ALL_FILE
		echo "/flyway/flyway -locations=filesystem:/flyway/databases/$DB_NAME -url=jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME -user=$DB_USER -password=$DB_PASSWORD migrate" >> $MIGRATE_ALL_FILE
	done

	chmod o+x $INFO_ALL_FILE
	chmod o+x $MIGRATE_ALL_FILE
fi

if [ "$1" = 'infoAll' ]; then
	eval "$INFO_ALL_FILE"
elif [ "$1" = 'migrateAll' ]; then
	eval "$MIGRATE_ALL_FILE"
elif [ "$1" = 'flyway' ]; then
	shift 1
	/flyway/flyway "$@"
else
	eval "$@"
fi

echo "READY" > /state

wait $STATE_SERVICE_PID