FROM openjdk:11-jdk
ADD ./docker-entrypoint.sh docker-entrypoint.sh
ENV JMX_PORT=\
    DEBUG_PORT=\
    MEMORY_OPTS=
ENTRYPOINT ["/docker-entrypoint.sh", "-jar", "/app.jar"]