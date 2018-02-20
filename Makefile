PROJECT_DIR := /Users/chris/Code/hashmap/Tempus/Tempus
CURRENT_DIR := $(shell pwd)

all:install copy build	

all-ldap: install copy build-ldap

install:
	mvn -f ${PROJECT_DIR}/pom.xml clean install -DskipTests

copy:
	cp ${PROJECT_DIR}/application/target/tempus.deb ${CURRENT_DIR}/tb

build:
	docker-compose stop
	docker-compose build
	docker-compose -f docker-compose.yml up -d

build-ldap:
	docker-compose stop
	docker-compose build
	docker-compose -f docker-compose.yml -f docker-compose-ldap.yml up -d