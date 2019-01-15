FROM gettyimages/spark:2.3.1-hadoop-3.0

RUN rm -rf /var/lib/apt/lists/*

# Set build path for Livy
ENV LIVY_VERSION=0.5.0
ENV LIVY_FILE=livy-$LIVY_VERSION-incubating-bin
ENV LIVY_HOME=/opt/livy
ENV SPARK_HOME=/usr/spark-2.3.1

WORKDIR /opt
RUN curl -OL http://mirror.its.dal.ca/apache/incubator/livy/0.5.0-incubating/$LIVY_FILE.zip && \
    unzip $LIVY_FILE.zip && \
    rm $LIVY_FILE.zip && \
    ln -s /opt/$LIVY_FILE $LIVY_HOME && \
    mkdir /var/log/livy && \
    ln -s /var/log/livy /opt/livy/logs && \
    cp /opt/livy/conf/log4j.properties.template /opt/livy/conf/log4j.properties

WORKDIR $LIVY_HOME
ADD livy.conf conf
RUN mkdir upload

RUN rm /usr/bin/python && ln -s /usr/bin/python3.4 /usr/bin/python

ADD runspark.sh ${LIVY_HOME}

RUN chmod a+x runspark.sh

CMD ${LIVY_HOME}/runspark.sh