FROM flink:1.11.2-scala_2.11-java11
ADD initialize-jobs.sh /
ADD docker-entrypoint-wrapper.sh /
ENTRYPOINT ["/docker-entrypoint-wrapper.sh"]