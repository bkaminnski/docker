FROM openjdk:8-jdk-alpine
ADD ./entrypoint.sh entrypoint.sh
ENV JMX_PORT=\
    DEBUG_PORT=\
    MEMORY_OPTS=
ENTRYPOINT ["/entrypoint.sh", "-jar", "/app.jar"]