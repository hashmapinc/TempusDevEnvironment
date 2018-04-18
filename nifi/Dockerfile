FROM apache/nifi:1.4.0
MAINTAINER Hashmap

ENV NIFI_VERSION 1.4.0
ENV NIFI_BASE_DIR /opt/nifi
ENV NIFI_HOME $NIFI_BASE_DIR/nifi-$NIFI_VERSION

USER root

RUN mkdir -p usr/local/configs
ADD basicConfig.json waterTank1.json waterTank2.json /usr/local/configs/
ADD nifi-simulator-bundle-nar-1.0-SNAPSHOT.nar ${NIFI_HOME}/lib
ADD nifi-nifiwitsml-nar-1.0-SNAPSHOT.nar ${NIFI_HOME}/lib
ADD nifi-tempus-nar-1.0-SNAPSHOT.nar ${NIFI_HOME}/lib
ADD flow.xml.gz ${NIFI_HOME}/conf

RUN chown nifi:nifi /usr/local/configs ${NIFI_HOME}/lib/nifi-simulator-bundle-nar-1.0-SNAPSHOT.nar ${NIFI_HOME}/lib/nifi-nifiwitsml-nar-1.0-SNAPSHOT.nar ${NIFI_HOME}/lib/nifi-tempus-nar-1.0-SNAPSHOT.nar ${NIFI_HOME}/conf/flow.xml.gz

USER nifi
# Startup NiFi
ENTRYPOINT ["bin/nifi.sh"]
CMD ["run"]