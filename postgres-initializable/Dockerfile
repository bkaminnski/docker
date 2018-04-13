FROM postgres
RUN apt-get update && apt-get install -y netcat
ADD state-service.sh /
ADD wait-for-postgres.sh /
ADD docker-entrypoint-wrapper.sh /
ENTRYPOINT ["/docker-entrypoint-wrapper.sh"]