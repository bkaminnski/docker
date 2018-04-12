#!/bin/sh

JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom"

if [ "x$JMX_PORT" = "x" ]; then
	echo "JMX disabled"
else
	echo "JMX_PORT: $JMX_PORT"
    JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.port=$JMX_PORT -Dcom.sun.management.jmxremote.rmi.port=$JMX_PORT -Djava.rmi.server.hostname=0.0.0.0 -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
fi

if [ "x$DEBUG_PORT" = "x" ]; then
	echo "Debug disabled"
else
	echo "DEBUG_PORT: $DEBUG_PORT"
    JAVA_OPTS="$JAVA_OPTS -Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=$DEBUG_PORT,suspend=n"
fi

if [ "x$MEMORY_OPTS" = "x" ]; then
	echo "No memory settings provided"
else
	echo "MEMORY_OPTS: $MEMORY_OPTS"
fi

exec java $JAVA_OPTS $MEMORY_OPTS $@