PROJECT_DIR := /Users/anuj/Projects/TempusCloud/Tempus
SIM_PROJECT_DIR := /Users/anuj/Projects/TempusCloud/nifi-simulator-bundle
API_DISCOVERY_DIR := /Users/anuj/Projects/TempusCloud/HashmapAnalyticsFramework/api-discovery
IDENTITY_SERVICE_DIR := /Users/anuj/Projects/TempusCloud/HashmapAnalyticsFramework/identity-service
METADATA_SERVICE_DIR := /Users/anuj/Projects/TempusCloud/HashmapAnalyticsFramework/metadata-api
DATA_QUALITY_SERVICE_DIR := /Users/anuj/Projects/TempusCloud/HashmapAnalyticsFramework/data-quality-service
CURRENT_DIR := $(shell pwd)

all:validate install copy build	

all-ldap: install copy build-ldap

validate:
	mvn -f ${PROJECT_DIR}/pom.xml validate
	mvn -f ${SIM_PROJECT_DIR}/pom.xml validate
	mvn -f ${API_DISCOVERY_DIR}/pom.xml validate
	mvn -f ${IDENTITY_SERVICE_DIR}/pom.xml validate
	mvn -f ${METADATA_SERVICE_DIR}/pom.xml validate
	mvn -f ${DATA_QUALITY_SERVICE_DIR}/pom.xml validate

install:
	mvn -f ${PROJECT_DIR}/pom.xml clean install -DskipTests
	mvn -f ${SIM_PROJECT_DIR}/pom.xml clean install -DskipTests
	mvn -f ${API_DISCOVERY_DIR}/pom.xml clean install -DskipTests
	mvn -f ${IDENTITY_SERVICE_DIR}/pom.xml clean install -DskipTests
	mvn -f ${METADATA_SERVICE_DIR}/pom.xml clean install -DskipTests
	mvn -f ${DATA_QUALITY_SERVICE_DIR}/pom.xml clean install -DskipTests

copy:
	cp ${PROJECT_DIR}/application/target/tempus.deb ${CURRENT_DIR}/tb
	cp ${SIM_PROJECT_DIR}/nifi-simulator-bundle-nar/target/nifi-simulator-bundle-nar-1.0-SNAPSHOT.nar ${CURRENT_DIR}/nifi
	cp ${API_DISCOVERY_DIR}/target/api-discovery.jar ${CURRENT_DIR}/api-discovery
	cp ${IDENTITY_SERVICE_DIR}/target/identity-service.jar ${CURRENT_DIR}/identity-service
	cp ${METADATA_SERVICE_DIR}/target/metadata-api.jar ${CURRENT_DIR}/metadata-api
	cp ${DATA_QUALITY_SERVICE_DIR}/target/data-quality-service.jar ${CURRENT_DIR}/data-quality

build:
	docker-compose stop
	docker-compose build
	docker-compose -f docker-compose.yml up -d

build-ldap:
	docker-compose stop
	docker-compose build
	docker-compose -f docker-compose.yml -f docker-compose-ldap.yml up -d