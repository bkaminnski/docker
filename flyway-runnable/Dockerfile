FROM boxfuse/flyway
RUN apt-get update \
    && apt-get install -y netcat \
    && rm /flyway/conf/flyway.conf \
    && mkdir /flyway/databases
ADD flyway.conf /flyway/conf/flyway.conf
ADD state-service.sh /
ADD docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]