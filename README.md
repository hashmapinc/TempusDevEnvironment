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
- [KUDU](#kudu)

## Requirements

* JDK 1.8 at a minimum
* Maven 3.1 or newer
* Docker (with compose)
* A machine with 8+ GB of RAM and preferably quad core
* The hashmapinc/thingsboard repository cloned on your local machine

### Configuring Docker

Make sure Docker has 8 GB of RAM and 4 cores allocated to it.

## Getting Started

To get started we must first clone this github repository.
    
    git clone https://github.com/hashmapinc/TempusDevEnvionment.git

*Note: On a slow connection, this might take a while*

Once the clone is completed change directory into the **TempusDevEnvironment** directory

    cd TempusDevEnvironment

### Configure the environment

The environment variables are stored in the .env file. Change the HOST_IP to the IP address of the docker host (whatever
machine is hosting the containers). For all the rest of the directories, point them to a location on the machine that exists. These
locations will persist data even when the docker containers are destroyed (i.e. persistant storage).

Next you will want to configure the Makefile so that the PROJECT_DIR variable is pointing to the location of the parent POM file in the cloned local thingsboard repository. 

Compile the thingsboard source and build the docker images (*Note: This WILL take a long time, as NiFi is almost 1 GB*)

    make all

At this point there will be a lot of information scrolling across the screen as the logs from each container will be comingled. The 
container creation process will take between 1-2.5 minutes. Once up the following containers will have been created:
- NiFi (http://localhost:9090/nifi/)
- Thingsboard (http://localhost:8080/)
- Zookeeper
- Kafka
- Spark (http://localhost:8181)
- Postgres (storage for data in development environments, not for production use)

### Enabling LDAP Security

The default installation with 'make all' doesn't use LDAP security. However, It can be changed to use LDAP server for authentication and thingsboard to authorize the user based on the authentication.

To enable LDAP authentication change the value of flag 'LDAP_AUTHENTICATION_ENABLED' to value 'true' in 'tb.env' and run the command 'make all-ldap' instead of 'make all' for installation. 

This will also bring up the docker containers with 'openldap' and a web inteface to access the LDAP server. 

The openldap server can be accessed via a web interface in browser on url 'http://localhost:9080' admin credentials are - 

Login DN: cn=admin,dc=example,dc=org 
Password: admin

When the enviroment is Up, The user which should be authenticated needs to be created in LDAP server. It can be done by importing a ldif file in following format on web interface at "http://localhost:9080".

dn: uid=tenant@thingsboard.org,dc=example,dc=org
objectclass: account
objectclass: simpleSecurityObject
objectclass: top
uid: tenant@thingsboard.org
userpassword: tenant


### Docker Compose Controls

Note: if you would like to bring up the environment in non-interactive mode use the following command instead:

    docker-compose up -d

To stop the containers execute the following command

    docker-compose stop

If no changes have been made you can executed the following command to bring up containers that were already created with either
the up or the build command

    docker-compose start

The NiFi installation will also come preloaded wtih the Hashmap Nifi-Simulator-Bundle and the associated flow to Thingsboard.

At this point the environment is up and running. Now we will build a sample flow.

## Usage

### To update thingsboard
Note: To update thingsboard, copy the thingsboard.deb file from the application/target directory of the thingsboard repo and place it in the /tb directory and build the container by running make build (this will be automated in a future release with hot code deploy)

### Add a device in thingsboard
Open the thingsboard UI by navigating to http://localhost:8080 using your browser. The default user name and password is as follows:

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/login.png" alt="Tempus"/>

User: tenant@thingsboard.org
Pass: tenant

Once logged in click on DEVICES in the left-hand menu. Add a device using the orange + symbol in the lower right hand. Fill in the following information:
- Name: Test Device
- Device Type: NiFi
- Leave "Is Gateway" unchecked
- Leave Description empty and click Add

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/Add%20Device.png" alt="Tempus"/>

Click on the newly added Test Device, under Details, click on Manage Credentials, and copy the access token.

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/device%20credentials.png" alt="Tempus"/>

### Setup the flow in NiFi

Navigate to NiFi (http://localhost:9090/nifi). A flow should already be created. Make sure all processors are stopped by clicking
the stop icon in the Operate panel.

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/operate%20panel.png" alt="Tempus"/>

Right-click on Publish MQTT that is connected to the GenerateTimeSeriesFlowFile processor. Click on Configure. Click on the properties tab, and for User name enter the access token that was copied above. All of the other options should remain the same. (Note that in order to pass the validation of the processor properties, the password is simply a space character. It is not actually used).

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/processor%20configuration.png" alt="Tempus"/>

Click Apply to close the properties window. Do the same thing for the PublishMQTT process connected to the GenerateFlowFile processor.

Start all the processors by clicking the play button in the Operate Panel.

Go back to thingsboard and go to the devices again by clicking on Devices in the left hand menu and clicking on Test Device. Click on 
Latest Telemetry to ensure you are recieving data (it should be refreshing approximately once per second). This data is coming from the flow that contains the GenerateTimeSeriesFlowFile processor. 

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/Test%20Device%20Telemetry.png" alt="Tempus"/>

Click on Attributes and ensure that there are 2 attributes (deviceType and GeoZone). This data comes from the JSON message that is in the GenerateFlowFile processor.

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/testdeviceatt.png" alt="Tempus"/>

At this point we have now successfully started transmitting data to Thingsboard from NiFi via MQTT. 

### Setup the connection to Kafka

The connection to Kafka is done via activating a plugin in thingsboard. Click on Plugins in the left-hand menu bar and click on the orange + in the lower right-hand corner to add a plugin. Click on the up arrow to import a plugin. In the /tb directory from where this repo was cloned, drag the file called kafka_plugin_for_spark_streaming_sample.json into the dashed box. Once it is done you should see the file name below the dashed box. Click Import. 

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/kafkapluginupload.png" alt="Tempus"/>

You should now see the Kafka Plugin for Spark Streaming Sample in a Suspended state. This plugin is where the Kafka producer would be confgured, but the configuration is already done. To view it, you can click on the plugin. On the main Plugin page click the play icon on the Kafka Plugin for Spark Streaming Sample to start the plugin. It should now say active. At this point all we have done is configured a kafka publisher from Thingsboard. 

### Building and Provisioning an App

At this point we will build a simple spark application that will read data from kafka and compute it and send it back to thingsboard. To do this we will need to perform the following steps.

Go to a directory where you can clone the Spark application and clone it with the following command:

    https://github.com/hashmapinc/TempusSparkApp.git

Enter the directory that was just cloned

    cd TempusSparkApp

Execute a Maven package goal with the following command

    mvn package

Once done the uber jar should be located in spark-kafka-streaming-integration/target. Copy the original-spark-kafka-streaming-integration-1.0.0.jar file to the directory specified in the SPARK_JAR_DIR specified in the .env file above.

At this point the jar is available to the spark container, but we will not yet start it. We will first start getting data flowing into kafka. The way to do this in thingsboard is to create a filter rule to route the data to the broker. 

Navigate to thingsboard again. Click on Rules from the left hand menu. Add a rule by clicking on the + icon in the bottom right hand corner and selecting the up arrow icon to import a rule. Drag the WindspeedTelemetryRule.json file from the TempusSparkApp repo root to the dashed box on the ui. Click Import. 

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/telemetry%20rule.png" alt="Tempus"/>

The WindSpeed Telemetry Rule should now be visible in the UI in the suspended state. Click the play icon to start it. (Note: the filter criteria can be seen by clicking on the Rule, more information can be found in the thingsboard documentation at thingsboard.io)

Now that the rule is active, data will automatically flow from nifi to kafka based on the filter criteria. As the NiFi processor is transmitting windSpeed there should now be data going to kafka. We will now verify this.

#### Verify Data Is In Kafka

Open a command line and peform a docker ps command to list the active containers:

    docker ps

Locate the kafka container (it will say kafka) and note the ID of the container. 

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/docker%20ps.png" alt="Tempus"/>

Execute bash in the container

    docker exec -t -i f217af1b5a96 /bin/bash

This will bring up a command line in the container. Navigate to kafka
    
    cd /opt/kafka_2.12-0.11.0.0/bin

Start the console consumer

    ./kafka-console-consumer.sh --zookeeper zk:2181 --topic weather-stations-data

You should see data streaming on the console. You have now verified you are receiving messaged. Hit ctrl-c to cancel. Type exit to leave the containter bash.

<img src="https://github.com/hashmapinc/hashmap.github.io/blob/master/devenv/data%20from%20kafka.png" alt="Tempus"/>

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









## KUDU

- Build Process (to be confirmed)
	- If you checked out kudu branch, just run make build command instead of make all (if this does not work, make sure you checkout kudu branch of thingsboard as well and then run make all)

- Configuration Check
	- In NIFI, you should see Kudu process group that will have complete Kudu enabled flow
	- In thingsboard, got to rules tab and do the following:
		- If you don't see system telemetry rule for depth, use depth_system_telemetry_rule.json from TempusDevEnvionment folder to define one
		- If you don't see time log rule for well, use well_time_log_rule.json from TempusDevEnvionment folder to define one
		- If you don't see depth rule for well, use well_depth_log_rule.json from TempusDevEnvionment folder to define one

- Verifying Program Execution
	- When you start running NIFI processors, data will start getting posted to thingsboard and to Kafka so both thingsboard devices and kafka consumer terminal should be checked to see if data is visible
	- Go to kafka container and change folder to /opt/kafka_2.12-0.11.0.2/bin and invoke the following command:
		./kafka-console-consumer.sh --zookeeper zk:2181 --topic well-log-data
	- To view thingsboard data, go to appropriate device cards and check attribute, telemetry and depth tabs.

- Spark Code (this section is expected to change quite a lot but for now the following things have to be done)
	- Use the source code zipped folder and build a fresh uber jar file
	- Transfer the uber jar file to SPARK_JAR_DIR folder as specified in your .env file
	- Create a subfolder in the SPARK_JAR_DIR called jars
	- In the jars subfolder, copy the jars necessary for KUDU - ImpalaJDBC4.jar, libthrift-0.9.0.jar, and TCLIServiceClient.jar
	- Identify spark container (LIVY) and go inside the container
	- Change folder to upload (cd upload)
	- Invoke the following command:
		spark-submit --master local[*] --jars jars/ImpalaJDBC4.jar,jars/libthrift-0.9.0.jar,jars/TCLIServiceClient.jar --class com.hashmap.tempus.ToKudu uber-ratechange-0.0.1-SNAPSHOT.jar kafka:9092 well-log-data INFO
	- Batches of data in the KUDU tables will start getting populated once every minute
	- The above command defaults the KUDU connection parameters to jdbc:impala://192.168.56.101:21050/kudu_witsml, demo/demo
	- The time_log table should be created with the following command:
		CREATE TABLE time_log (nameWell STRING, nameWellbore STRING, nameLog STRING, mnemonic STRING, ts STRING, value DOUBLE, PRIMARY KEY (nameWell, nameWellbore, nameLog, mnemonic, ts)) STORED AS KUDU;
	- The depth_log table should be created with the following command:
		CREATE TABLE depth_log (nameWell STRING, nameWellbore STRING, nameLog STRING, mnemonic STRING, depthString STRING, depth DOUBLE, value DOUBLE, PRIMARY KEY (nameWell, nameWellbore, nameLog, mnemonic, depthString)) STORED AS KUDU;
