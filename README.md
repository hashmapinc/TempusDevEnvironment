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

To build our development environment, we start with a clone of Tempus (dev branch). 

    	git clone https://github.com/hashmapinc/Tempus -b dev

We will also require following 3 github repositories:
    
    	git clone https://github.com/hashmapinc/TempusDevEnvionment
    	git clone https://github.com/hashmapinc/nifi-simulator-bundle
	git clone https://github.com/hashmapinc/HashmapAnalyticsFramework

*Note: On a slow connection, this might take a while*

Once the clones are completed change directory into the **TempusDevEnvironment** directory

    	cd TempusDevEnvironment

### Configure the environment

All Tempus environment variables are stored in .env file.

Create a directory say 'data' in your home directory and create a subdirectory structure as follows:

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

You should also update the Makefile to point following two variables to the directory where Hashmap Analytics Framework is installed, as below:

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
- Identity Service
- api_discovery

Tempus Development Environment is automatically built with Test Data. So you can run demos directly without further setup.

### Enabling LDAP Security - Please skip this Step for now.

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

<<< REPLACE WITH Tank 123>>

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/Add%20Device.png" alt="Tempus"/>

 Under Details, click on Manage Credentials, and copy the access token.

<<< REPLACE WITH CopyAccessToken>>

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/device%20credentials.png" alt="Tempus"/>

### Setup the flow in NiFi

Navigate to NiFi (http://localhost:9090/nifi). A flow called nifi should already be created. Make sure all processors are stopped by clicking the stop icon in the Operate panel. You should see three flows - Tank 123, Tank 456 and OPC.

<<<REPLACE WITH NIFI-Processes>>>

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/operate%20panel.png" alt="Tempus"/>

Double-click on Publish MQTT that is connected to the GenerateTimeSeriesFlowFile processor. Click on Configure. Click on the properties tab, and for User name enter the access token that was copied above. All of the other options should remain the same. (Note that in order to pass the validation of the processor properties, the password is simply a space character. It is not actually used).

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/processor%20configuration.png" alt="Tempus"/>

Click Apply to close the properties window. Do the same thing for the PublishMQTT process connected to the GenerateFlowFile processor.

Start all the processors by clicking the play button in the Operate Panel.

Go back to thingsboard and go to the devices again by clicking on Devices in the left hand menu and clicking on Test Device. Click on 
Latest Telemetry to ensure you are receiving data (it should be refreshing approximately once per second). This data is coming from the flow that contains the GenerateTimeSeriesFlowFile processor. 

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/Test%20Device%20Telemetry.png" alt="Tempus"/>

Click on Attributes and ensure that there are 2 attributes (Attn and waterTankLevel). This data comes from the JSON message that is in the GenerateFlowFile processor.

<<< REPLACE WITH TelemetryData >>>
<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/testdeviceatt.png" alt="Tempus"/>

At this point we have now successfully started transmitting data to Thingsboard from NiFi via MQTT. 

Repeat the same steps for device 'Tank 456'.

### Setup the connection to Kafka

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

To view the data in Tempus, select Devices, then select Tank 123 (or Tank 456) and then click on Latest Telemetry tab. You should see the latest vales of tags received from the device. Attributes tab will display the list of tags attached to that device. 



#### Submitting the Spark App

##### Create the Spark Gateway
Now that we know that we have data flowing into Kafka we can now process the data with Spark. Before we submit the application to spark, we have to create our gateway in thingsboard to receive the calculated data from Spark.

Go back to the thingsboard UI and click Devices in the left-hand menu.

Add a device with the orange + icon in the bottom right hand corner. Fill in the following information:
Name: Spark Gateway
Device type: Gateway
Check Is Gateway
Leave Description blank.

Click Add.

Click on the newly added Spark gateway and click on Manage Credentials, take note of the access token.

#### Submit the app
Now that we have all the endpoints created, we can submit the spark app.

Open a command line and peform a docker ps command to list the active containers:

    docker ps

Locate the spark container (it will say spark) and note the ID of the container. 

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/spark%20ps.png" alt="Tempus"/>

Execute bash in the container

    docker exec -t -i 13c522dec425 /bin/bash

The working directory of this container is the Spark home. Navigate to the bin directory

    cd bin

Execute the following spark-submit

    spark-submit --class org.thingsboard.samples.spark.SparkKafkaStreamingDemoMain /usr/local/apps/spark-kafka-streaming-integration-1.0.0.jar -kafka kafka:9092 -mqttbroker tcp://tb:1883 -token aplMzkUg6ziNvfKIOLjL -topic weather-stations-data -window 10000

The parameters are as follows:
- Kafka - the location of the broker
- mqttbroker - the thingsboard MQTT broker
- token the token copied from above from the Spark Gateway
- topic - the topic to read from on kafka (confgured in the Rule)
- window - the window to calculate over

the --class parameter is the entrypoint to the spark application.

Within 20 seconds you should see a new device under Devices called Zone A. This will contain the data that was being calculated by the spark application. This can be seen by clicking on the Zone A device and clicking on Latest Telemetry 

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/zone%20a%20telemetry.png" alt="Tempus"/>

You can tick the box next to windSpeed and display it on a Widget. From the Bundles choose chart, and choose a line chart. Click Add to dashboard.

Choose create a new dashboard and call it WindSpeed. Click Add. 

Click on Dashboard from the menu on the left and click WindSpeed. Click on the pencil in the lower right hand to modify the dashboard. 

Click the orange + icon in the lower right to add another widget. Choose the document icon to create a new widget.  Select Analogue Gauge.

Click +Add to add a data source. For the Entity Alias Type in Test Device, and click Create A New One from the pop up. Chose Filter type as Device Type, and type in NiFi in the Device Type. 

In the timeseries box, click and choose windSpeed. Click Add. 

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/gauge%20windspeed.png" alt="Tempus"/>

Click the orange checkmark in the lower right to save the changes. 

You are now visualizing the raw data and calculated data on one screen.








