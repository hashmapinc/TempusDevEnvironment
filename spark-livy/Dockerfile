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
RUN mkdir logs && mkdir upload

RUN rm /usr/bin/python && ln -s /usr/bin/python3.4 /usr/bin/python

RUN bin/livy-server start

WORKDIR $SPARK_HOME

RUN pip install numpy

CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]