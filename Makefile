PROJECT_DIR := /Users/miteshrathore/tempus/feature_workspace/Tempus
GATEWAY_DIR := /Users/miteshrathore/tempus/feature_workspace/thingsboard-gateway
CURRENT_DIR := $(shell pwd)

all:install copy build

all-ldap: install copy build-ldap

install:
	mvn -f ${PROJECT_DIR}/pom.xml clean install -DskipTests
	mvn -f ${GATEWAY_DIR}/pom.xml clean install -DskipTests

copy:
	cp ${PROJECT_DIR}/application/target/tempus.deb ${CURRENT_DIR}/tb
	cp ${GATEWAY_DIR}/target/tb-gateway.deb ${CURRENT_DIR}/tb-gateway

build:
	docker-compose stop
	docker-compose build
	docker-compose up

