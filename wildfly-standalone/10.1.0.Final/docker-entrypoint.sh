#!/bin/bash

set -e

./state-service.sh &

if  [ "x" != "x$WAIT_FOR" ]; then
	for WAITING in $WAIT_FOR; do
		# WAITING with pattern "HOST:PORT:EXPECTED_STRING"
		WAITING_VALUES=(${WAITING//;/ })
		HOST=${WAITING_VALUES[0]}
		PORT=${WAITING_VALUES[1]}
		EXPECTED=${WAITING_VALUES[2]}
		
		until nc $HOST $PORT | grep $EXPECTED; do
			echo "Waiting for $HOST:$PORT to respond with $EXPECTED"
			sleep 1
		done
	done
fi

INIT_CLI_FILE=$WILDFLY_HOME/init.cli

# Generate and run init cli only if it does not exist yet
if [[ ! -f "$INIT_CLI_FILE" ]]; then
	${WILDFLY_HOME}/bin/add-user.sh admin ${WILDFLY_PASSWORD} --silent
	
	echo "embed-server --std-out=echo --server-config=standalone-full.xml" > $INIT_CLI_FILE
	echo "module add --name=io.jsonwebtoken --resources=/wildfly-libs/jjwt-0.9.0.jar --dependencies=com.fasterxml.jackson.core.jackson-core,com.fasterxml.jackson.core.jackson-annotations,com.fasterxml.jackson.core.jackson-databind,javax.xml.bind.api,javax.api" >> $INIT_CLI_FILE
	echo "module add --name=org.postgres --resources=/wildfly-libs/postgresql-42.2.2.jar --dependencies=javax.api,javax.transaction.api" >> $INIT_CLI_FILE
	echo "/subsystem=datasources/jdbc-driver=postgres:add(driver-name=\"postgres\",driver-module-name=\"org.postgres\",driver-class-name=org.postgresql.Driver)" >> $INIT_CLI_FILE
	for POSTGRES_DATASOURCE in $POSTGRES_DATASOURCES; do
		# POSTGRES_DATASOURCE with pattern "HOST;PORT;SERVICE_NAME;PASSWORD"
		DATASOURCE_VALUES=(${POSTGRES_DATASOURCE//;/ })
		HOST=${DATASOURCE_VALUES[0]}
		PORT=${DATASOURCE_VALUES[1]}
		SERVICE_NAME=${DATASOURCE_VALUES[2]}
		PASSWORD=${DATASOURCE_VALUES[3]}
		
		JNDI_NAME="java:jboss/datasources/${SERVICE_NAME}"
		DATASOURCE_NAME="${SERVICE_NAME}DS"
		CONNECTION_URL="jdbc:postgresql://${HOST}:${PORT}/${SERVICE_NAME}"
		USER_NAME="${SERVICE_NAME}"
		
		echo "data-source add --jndi-name=${JNDI_NAME} --name=${DATASOURCE_NAME} --connection-url=${CONNECTION_URL} --driver-name=postgres --user-name=${USER_NAME} --password=${PASSWORD}" >> $INIT_CLI_FILE
	done
	for JMS_TOPIC in $JMS_TOPICS; do
		# JMS_TOPIC with pattern "TOPIC_ADDRESS;ENTRIES"
		TOPIC_VALUES=(${JMS_TOPIC//;/ })
		TOPIC_ADDRESS=${TOPIC_VALUES[0]}
		ENTRIES=${TOPIC_VALUES[1]}

		echo "jms-topic add --topic-address=${TOPIC_ADDRESS} --entries=${ENTRIES}" >> $INIT_CLI_FILE
	done
	echo "stop-embedded-server" >> $INIT_CLI_FILE
	
	cat $INIT_CLI_FILE
	${WILDFLY_HOME}/bin/jboss-cli.sh --file=$INIT_CLI_FILE
fi

if [ "$1" = 'wildfly' ]; then
	$WILDFLY_HOME/bin/standalone.sh -c standalone-full.xml -b=0.0.0.0 -bmanagement=0.0.0.0 -DjwtSignature=$JWT_SIGNATURE
fi

exec "$@"