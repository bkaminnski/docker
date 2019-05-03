FROM openjdk:8-jdk-alpine
ADD ./docker-entrypoint.sh docker-entrypoint.sh
RUN apk --update add bash
ENV JMX_PORT=\
    DEBUG_PORT=\
    MEMORY_OPTS=
ENTRYPOINT ["/docker-entrypoint.sh", "-jar", "/app.jar"]