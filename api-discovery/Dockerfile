FROM openjdk:8-jdk

ADD api-discovery.jar app.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]