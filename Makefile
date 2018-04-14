PROJECT_DIR := /Users/fron/workarea/Tempus
SIM_PROJECT_DIR := /Users/fron/workarea/nifi-simulator-bundle
OPC_PROJECT_DIR := /Users/fron/workarea/nifi-opcua-bundle
CURRENT_DIR := $(shell pwd)

all:install copy build	

all-ldap: install copy build-ldap

install:
	mvn -f ${PROJECT_DIR}/pom.xml clean install -DskipTests
	mvn -f ${SIM_PROJECT_DIR}/pom.xml clean install
	mvn -f ${OPC_PROJECT_DIR}/pom.xml clean install

copy:
	cp ${PROJECT_DIR}/application/target/tempus.deb ${CURRENT_DIR}/tb
	cp ${SIM_PROJECT_DIR}/nifi-simulator-bundle-nar/target/nifi-simulator-bundle-nar-1.0-SNAPSHOT.nar ${CURRENT_DIR}/nifi
	cp ${OPC_PROJECT_DIR}/nifi-opcua-bundle/nifi-opcua-bundle-nar/target/nifi-opcua-bundle-nar-0.0.1-SNAPSHOT.nar ${CURRENT_DIR}/nifi

build:
	docker-compose stop
	docker-compose build
	docker-compose -f docker-compose.yml up -d

build-ldap:
	docker-compose stop
	docker-compose build
	docker-compose -f docker-compose.yml -f docker-compose-ldap.yml up -d
