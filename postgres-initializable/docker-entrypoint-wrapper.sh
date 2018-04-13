#!/bin/bash

set -e

/state-service.sh &
/wait-for-postgres.sh &

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

INIT_DATABASES_FILE=/docker-entrypoint-initdb.d/init_databases.sh

# Generate and run init cli only if it does not exist yet
if [[ ! -f "$INIT_DATABASES_FILE" ]]; then
	echo '#!/bin/bash' > $INIT_DATABASES_FILE
	echo 'set -e' >> $INIT_DATABASES_FILE
	file_env 'POSTGRES_USER' 'postgres'
	echo "psql -v ON_ERROR_STOP=1 --username \"$POSTGRES_USER\" <<-EOSQL" >> $INIT_DATABASES_FILE
	for INITIAL_DATABASE in $INITIAL_DATABASES; do
		# INITIAL_DATABASE with pattern "SERVICE_NAME;PASSWORD"
		DATABASE_VALUES=(${INITIAL_DATABASE//;/ })
		SERVICE_NAME=${DATABASE_VALUES[0]}
		PASSWORD=${DATABASE_VALUES[1]}
		
		DB_USER=$SERVICE_NAME
		DB_NAME=$SERVICE_NAME
		
		echo "CREATE USER $DB_USER WITH PASSWORD '$PASSWORD';" >> $INIT_DATABASES_FILE
		echo "CREATE DATABASE $DB_NAME;" >> $INIT_DATABASES_FILE
		echo "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" >> $INIT_DATABASES_FILE
	done
	echo 'EOSQL' >> $INIT_DATABASES_FILE
fi

if [ "$1" = 'postgres' ]; then
	/docker-entrypoint.sh "$@"
fi

exec "$@"