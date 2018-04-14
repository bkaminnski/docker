FROM bkaminnski/wildfly-base:10.1.0.Final
RUN rm ${WILDFLY_HOME}/bin/standalone.conf \
  && mkdir -p /wildfly-libs \
  && curl -o /wildfly-libs/postgresql-42.2.2.jar https://jdbc.postgresql.org/download/postgresql-42.2.2.jar \
  && curl -o /wildfly-libs/jjwt-0.9.0.jar http://central.maven.org/maven2/io/jsonwebtoken/jjwt/0.9.0/jjwt-0.9.0.jar
ADD standalone.conf ${WILDFLY_HOME}/bin/
ADD state-service.sh /
ADD docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]