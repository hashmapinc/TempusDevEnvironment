FROM gettyimages/spark

RUN rm -rf /var/lib/apt/lists/*

# Set build path for Livy
ENV LIVY_VERSION=0.3.0
ENV LIVY_FILE=livy-server-$LIVY_VERSION
ENV LIVY_HOME=/usr/$LIVY_FILE

WORKDIR /usr
RUN curl -OL http://archive.cloudera.com/beta/livy/$LIVY_FILE.zip
RUN unzip $LIVY_FILE.zip
WORKDIR $LIVY_HOME
ADD livy.conf conf
RUN mkdir logs && mkdir upload

RUN rm /usr/bin/python && ln -s /usr/bin/python3.4 /usr/bin/python

ADD runspark.sh ${LIVY_HOME}

RUN chmod a+x runspark.sh

CMD ${LIVY_HOME}/runspark.sh