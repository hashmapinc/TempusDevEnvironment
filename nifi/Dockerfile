FROM openjdk:8
MAINTAINER Apache NiFi <dev@nifi.apache.org>

ARG UID=1000
ARG GID=50
ARG NIFI_VERSION=1.3.0

ENV NIFI_BASE_DIR /opt/nifi
ENV NIFI_HOME $NIFI_BASE_DIR/nifi-$NIFI_VERSION
ENV NIFI_BINARY_URL https://archive.apache.org/dist/nifi/$NIFI_VERSION/nifi-$NIFI_VERSION-bin.tar.gz

# Setup NiFi user
RUN groupadd -g $GID nifi || groupmod -n nifi `getent group $GID | cut -d: -f1`
RUN useradd --shell /bin/bash -u $UID -g $GID -m nifi
RUN mkdir -p $NIFI_HOME

# Download, validate, and expand Apache NiFi binary.
RUN curl -fSL $NIFI_BINARY_URL -o $NIFI_BASE_DIR/nifi-$NIFI_VERSION-bin.tar.gz \
	&& echo "$(curl $NIFI_BINARY_URL.sha256) *$NIFI_BASE_DIR/nifi-$NIFI_VERSION-bin.tar.gz" | sha256sum -c - \
	&& tar -xvzf $NIFI_BASE_DIR/nifi-$NIFI_VERSION-bin.tar.gz -C $NIFI_BASE_DIR \
	&& rm $NIFI_BASE_DIR/nifi-$NIFI_VERSION-bin.tar.gz

ADD nifi-simulator-bundle-nar-1.0-SNAPSHOT.nar ${NIFI_HOME}/lib

RUN mkdir usr/local/configs

ADD basicConfig.json /usr/local/configs

RUN chown -R nifi:nifi $NIFI_HOME

# Web HTTP Port
EXPOSE 9090

# Remote Site-To-Site Port
EXPOSE 9191

USER nifi

# Startup NiFi
CMD $NIFI_HOME/bin/nifi.sh run