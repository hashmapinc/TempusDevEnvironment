<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/images/tempus/Tempus_Logo_Black_with_TagLine.png" width="950" height="245" alt="Hashmap, Inc Tempus"/>
[![License](http://img.shields.io/:license-Apache%202-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.txt)

# Tempus Development Environment

This environment is meant to be used to develop and test Tempus applications and the Tempus framework.
<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/images/tempus/Tempus_High_Level.png" alt="Tempus"/>

The intention is to provide an IoT, Streaming Analytics, and Storage Platform on top of Big Data. The solution is based on the following components.
- Storage
    * HBase
    * Phoenix
- Processing
    * Spark
- Ingest
    * NiFi
    * Thingsboard
    * Kafka
- Visualization
    * Thingsboard
- Security
    * LDAP (Optional)

This readme will take you through how to setup the development environment for development, and run a sample end-to-end application.

## Table of Contents

- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Usage](#usage)

## Requirements

* JDK 1.8 at a minimum
* Maven 3.1 or newer
* Git 2.7 or higher
* Docker (with compose)
* A machine with 16 GB of RAM and preferably quad core
* Preferred OS is MacOS or Linux
* The hashmapinc/thingsboard repository cloned on your local machine

### Configuring Docker

Make sure Docker has 8 GB of RAM and 4 cores allocated to it. Docker commands require use of 'sudo'. To give yourself unrestricted access to docker, use this command:

    sudo usermod -a -G docker $USER

## Getting Started

To get started we must clone the TempusDevEnvironment repo from github:

        git clone https://github.com/hashmapinc/TempusDevEnvionment

In adiition, we also need following 3 github repositories to setup our dev environment:
   
        git clone https://github.com/hashmapinc/HashmapAnalyticsFramework
        git clone https://github.com/hashmapinc/Tempus -b dev --clone dev branch
        https://github.com/hashmapinc/nifi-simulator-bundle

*Note: On a slow connection, this might take a while*

Once the clones are completed change directory into the **TempusDevEnvironment** directory

        cd TempusDevEnvironment

### Configure the environment

All Tempus environment variables are stored in .env file.

Create a directory say 'data' in your local machine and create a subdirectory structure as follows:

> data
 >> cassandra
 >> hsqldb
 >> kafka
 >> ldap
 >> nifi
    >>> content
    >>> db
    >>> flowfile
    >>> logs
    >>> provenance
 >> postgres
 >> spark

These directories will hold the data from various Tempus processes. However, these processes will execute within docker containers, so we must point tell docker to point them to these physical directories. These locations will persist data even when the docker containers are destroyed (i.e. persistent storage).

Edit the .env file and point the environment variables to their respective directories using full path. For example:

NIFI_DATA_DIR=/home/ubuntu/data/nifi

Next you will want to configure the Makefile so that the PROJECT_DIR variables are pointing to the location of the parent POM file in the cloned local Tempus & nifi-simulator-bundle repositories. For example

PROJECT_DIR := /home/ubuntu/Tempus
SIM_PROJECT_DIR := /home/ubuntu/nifi-simulator-bundle

You also need to point following variables to HashmapAnalyticsFrameowrk directory on your machine. For example:

API_DISCOVERY_DIR := /home/ubuntu/HashmapAnalyticsFramework/api-discovery
IDENTITY_SERVICE_DIR := /home/ubuntu/HashmapAnalyticsFramework/identity-service

Go to Tempus root directory, where pom.xml is present and run 'mvn validate'. After you see the 'BUILD SUCCESS' message return to
TempusDevEnvironment root directory

Compile Tempus and nifi-simulator bundle source and build the docker images (*Note: This WILL take a long time, as NiFi is almost 1 GB*)

        make all

At this point there will be a lot of information scrolling across the screen as the logs from each container will be displayed. The
container creation process may take between 1-2.5 hours depending upon the wifi speed. Once up the following containers will have been created:

- NiFi (http://localhost:9090/nifi/)
- Thingsboard (tb) (http://localhost:8080/)
- Zookeeper (zk)
- Kafka
- Spark (http://localhost:8181)
- Postgres (storage for data in development environments, not for production use)
- cassandra
- identity_service
- api_discovery

You can use 'docker ps' command to verify this anytime.

Tempus Development Environment is automatically built with Test Data. So you can run demos directly without further setup.

### Enabling LDAP Security - (Please skip this Step for now.)

The default installation with 'make all' doesn't use LDAP security. However, It can be changed to use LDAP server for authentication and thingsboard to authorize the user based on the authentication.

To enable LDAP authentication change the value of flag 'LDAP_AUTHENTICATION_ENABLED' to value 'true' in 'tb.env' and run the command 'make all-ldap' instead of 'make all' for installation.

This will also bring up the docker containers with 'openldap' and a web interface to access the LDAP server.

The openldap server can be accessed via a web interface in browser on url 'http://localhost:9080' admin credentials are -

Login DN: cn=admin,dc=example,dc=org
Password: admin

When the environment is Up, The user which should be authenticated needs to be created in LDAP server. It can be done by importing a ldif file in following format on web interface at "http://localhost:9080".

dn: uid=tenant@thingsboard.org,dc=example,dc=org
objectclass: account
objectclass: simpleSecurityObject
objectclass: top
uid: tenant@thingsboard.org
userpassword: tenant


### Docker Compose Controls

Note: if you would like to bring up the environment in non-interactive mode use the following command from TempusDevEnvironment root directory:

    docker-compose up -d

To stop the containers execute the following command

    docker-compose stop

If no changes have been made you can executed the following command to bring up containers that were already created with either
the up or the build command

    docker-compose start

The NiFi installation will also come preloaded wtih the Hashmap Nifi-Simulator-Bundle and the associated flow to Thingsboard.

At this point the environment is up and running. Now we will build a sample flow.

## Usage

### Add a device in thingsboard
Open the thingsboard UI by navigating to http://localhost:8080 using your browser. The default user name and password is as follows:

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/login.png" alt="Tempus"/>

- Tenant User/Pass: demo@hashmapinc.com/tenant
- (Note: System Admin User/Pass: sysadmin@hashmapinc.com/sysadmin)

Once logged in click on DEVICES in the left-hand menu and select Tank 123.'Tank 123' and 'Tank 456' test devices have already been created for demo purpose and you should use them.

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/Tank123.png" alt="Tempus"/>

 Under Details, click on Manage Credentials, and copy the access token.


<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/CopyAccessToken.png" alt="Tempus"/>

### Setup the flow in NiFi

Navigate to NiFi (http://localhost:9090/nifi). A flow called nifi should already be created. Make sure all processors are stopped by clicking the stop icon in the Operate panel. You should see three flows - Tank 123, Tank 456 and OPC.

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/Nifi-Processes.png" alt="Tempus"/>

Double-click on Publish MQTT that is connected to the GenerateTimeSeriesFlowFile processor. Click on Configure. Click on the properties tab, and for User name enter the access token that was copied above. All of the other options should remain the same. (Note that in order to pass the validation of the processor properties, the password is simply a space character. It is not actually used).

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/processor%20configuration.png" alt="Tempus"/>

Click Apply to close the properties window. Do the same thing for the PublishMQTT process connected to the GenerateFlowFile processor.

Start all the processors by clicking the play button in the Operate Panel.

Go back to thingsboard and go to the devices again by clicking on Devices in the left hand menu and clicking on Test Device. Click on
Latest Telemetry to ensure you are receiving data (it should be refreshing approximately once per second). This data is coming from the flow that contains the GenerateTimeSeriesFlowFile processor.

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/Test%20Device%20Telemetry.png" alt="Tempus"/>

Click on Attributes and ensure that there are 2 attributes (Attn and waterTankLevel). This data comes from the JSON message that is in the GenerateFlowFile processor.

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/TelemetryData.png" alt="Tempus"/>

At this point we have now successfully started transmitting data to Thingsboard from NiFi via MQTT.

Repeat the same steps for device 'Tank 456'.

### Setup the connection to Kafka - (This has already been done and you should see Kafka Plug In)

The connection to Kafka is done via activating a plugin in thingsboard. Click on Plugins in the left-hand menu bar and click on the orange + in the lower right-hand corner to add a plugin. Click on the up arrow to import a plugin. In the /tb directory from where this repo was cloned, drag the file called kafka_plugin_for_spark_streaming_sample.json into the dashed box. Once it is done you should see the file name below the dashed box. Click Import.

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/KafkaPlugIn.png" alt="Tempus"/>

You should now see the Kafka Plugin for Spark Streaming Sample in a Suspended state. This plugin is where the Kafka producer would be confgured, but the configuration is already done. To view it, you can click on the plugin. On the main Plugin page click the play icon on the Kafka Plugin for Spark Streaming Sample to start the plugin. It should now say active. At this point all we have done is configured a kafka publisher from Thingsboard.

Kafka Plug In will publish the data to kafka cluster running in Kafka docker image under a topic called water-tank-level-data.

To see the data in Kafka, run

    docker ps

You should see a list of containers running on your machine. Locate the Kafka container and copy its id to clipboard. Then rn following command to enter the docker image:

    docker exec -t -i <image> bash

You should now see the # prompt of Kafka image. Go to /opt/kafka/bin directory and run following command to see the topic list:

    ./kafka-topics.sh --zookeeper zk:2181 --list

This should list water-tank-level-data topic. To see the data being published under this topic, run a Kafka console consumer with following command

    ./kafka-console-consumer.sh --zookeeper zk:2181 --topic water-tank-level-data

You should see data being displayed as it is published. If you stop the flow in Nifi, this data will stop.

Repeat the same steps for Tank 456. At this stage, you have successfully setup a MQTT device to monitor water level of Tanks, publish it to Thingsboard gateway, apply a rule (value is not null), which in turn calls Kafka Plug In action, which starts a Kafka Publisher and publishes the data to Kafka under specified topic.

You can view the details of Water Tank Telemetry Rule to understand functionality of Thingsboard Rule Engine.

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/WaterTankTelemetryRule.png" alt="Tempus"/>

### Building and Provisioning an App

At this point we will build a simple spark application that will read data from kafka and perform some computations on it and send the results back to thingsboard. For this we have created a set of demo applications and bundled them into project tempus-extensions

To explore these modules further, we will need to perform the following steps.

Go to a directory where you can clone the Spark application and clone it with the following command:

    git clone https://github.com/hashmapinc/tempus-extensions

Enter the directory that was just cloned and build the application

    cd tempus-extensions
    mvn clean package

Build should create multiple jar files - one of each project, which is located within the target of the respective project. For example, we will run following two applications and their jars are located at

    tempus-rateofchange/ratechange/target/ratechange-0.0.1-SNAPSHOT.jar
    tempus-WaterLevelAggregator/target/WaterLevelAggregator-0.0.1-SNAPSHOT.jar

To run a spark application, list all running containers with

    docker ps

Locate Spark container and copy its id to clipboard. Then run following command to copy the jar files to Spark container:

    docker cp tempus-rateofchange/ratechange/target/ratechange-0.0.1-SNAPSHOT.jar <image>:/usr/livy-server-0.3.0
    docker cp tempus-WaterLevelAggregator/target/WaterLevelAggregator-0.0.1-SNAPSHOT.jar <image>:/usr/livy-server-0.3.0

Now got to Spark container

    docker exec -t -i <image> bash

#### Submitting the Spark App

Now we are ready to run the Apps. To run WaterLevelAggregator, use following command:

spark-submit --class com.hashmapinc.tempus.spark.WaterLevelAggregator WaterLevelAggregator-0.0.1-SNAPSHOT.jar -kafka kafka:9092 -mqttbroker tcp://tb:1883 -token GATEWAY_ACCESS_TOKEN -topic water-tank-level-data -window 10000

The parameters are as follows:
- Kafka - the location of the broker
- mqttbroker - the thingsboard MQTT broker
- token the token copied from above from the Spark Gateway
- topic - the topic to read from on kafka (configured in the Rule)
- window - batching period, the window to perform aggregations

the --class parameter is the entrypoint to the spark application.

This App reads the Water Tank level from Kafka, averages it for a period for each tank and pushes the average level for each tank back in Thingsboard under the same device. You should be able to see the average values under Device Telemetry tab. (As an exercise, try to change this to publish avearge values under a different device name).

Similarly to run Rate of Change App, use following command:

spark-submit --class com.hashmap.tempus.WaterLevelPredictor ratechange-0.0.1-SNAPSHOT.jar tcp://tb:1883 kafka:9092 water-tank-level-data 70.0 10000 GATEWAY_ACCESS_TOKEN DEBUG=INFO

This application reads the water tank level from Kafka, computes the time it will take it to reach specified level (70% in our case) and publishes that back to device telemetry in Thingsboard, which can be mapped to a Dashboard.





