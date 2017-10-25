PROJECT_DIR := /Users/chris/Code/hashmap/thingsboard
GATEWAY_DIR := /home/pc/gateway/thingsboard-gateway
CURRENT_DIR := $(shell pwd)

all:install copy build	

install:
	mvn -f ${PROJECT_DIR}/pom.xml clean install -DskipTests
	mvn -f ${GATEWAY_DIR}/pom.xml clean install -DskipTests

copy:
	cp ${PROJECT_DIR}/application/target/thingsboard.deb ${CURRENT_DIR}/tb
	cp ${GATEWAY_DIR}/target/tb-gateway.deb ${CURRENT_DIR}/tb-gateway

build:
	docker-compose stop
	docker-compose build
	docker-compose up -d