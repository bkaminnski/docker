FROM openjdk:8-jdk-alpine
ENV VERSION 10.1.0.Final
ENV INSTALL_DIR /opt
ENV WILDFLY_HOME ${INSTALL_DIR}/wildfly-${VERSION}
ENV DEPLOYMENT_DIR ${WILDFLY_HOME}/standalone/deployments/
RUN apk --update add bash curl \
  && curl -O http://download.jboss.org/wildfly/${VERSION}/wildfly-${VERSION}.zip \
  && mkdir -p ${INSTALL_DIR} \
  && unzip wildfly-${VERSION}.zip -d ${INSTALL_DIR} \
  && rm wildfly-${VERSION}.zip \
  && chmod a+x ${WILDFLY_HOME}/bin/standalone.sh 
EXPOSE 8080 9990