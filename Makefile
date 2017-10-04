PROJECT_DIR := /Users/jay/Projects/hashmap/thingsboard
CURRENT_DIR := $(shell pwd)

all:install copy build	

install:
	mvn -f ${PROJECT_DIR}/pom.xml clean install -DskipTests

copy:
	cp ${PROJECT_DIR}/application/target/thingsboard.deb ${CURRENT_DIR}/tb

build:
	docker-compose stop
	docker-compose build
	docker-compose up -d