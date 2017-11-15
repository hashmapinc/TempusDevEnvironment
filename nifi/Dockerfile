FROM apache/nifi:1.4.0
MAINTAINER Hashmap

ENV NIFI_VERSION 1.4.0
ENV NIFI_BASE_DIR /opt/nifi
ENV NIFI_HOME $NIFI_BASE_DIR/nifi-$NIFI_VERSION

RUN mkdir usr/local/configs

ADD basicConfig.json /usr/local/configs

ADD nifi-simulator-bundle-nar-1.0-SNAPSHOT.nar ${NIFI_HOME}/lib
ADD flow.xml.gz ${NIFI_HOME}/conf
USER root
RUN chown -R nifi:nifi $NIFI_HOME
USER nifi
# Startup NiFi
CMD $NIFI_HOME/bin/nifi.sh run