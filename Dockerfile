FROM openjdk:8-jdk-alpine

## Uncomment for localized builds only otherwise this is passed via springapp-deployment.yml template
#ARG LICENSE_KEY
#ENV NEW_RELIC_LICENSE_KEY ${LICENSE_KEY:-YOUR_LICENSE_KEY}

## Refer to Maven build -> finalName
ARG JAR_FILE=docker-spring-boot/target/spring-boot-web.jar

# Action: cd /opt/app
WORKDIR /opt/app

# Action: cp target/spring-boot-web.jar /opt/app/spring-boot-web.jar
COPY ${JAR_FILE} spring-boot-web.jar

## Tradional New Relic agent bundle practices
#RUN apk --no-cache add curl tar gzip

#RUN curl -SL https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip -o /opt/app/newrelic-java.zip
#RUN unzip /opt/app/newrelic-java.zip -d /opt/app
#RUN rm -f /opt/app/newrelic-java.zip
#RUN rm -f /opt/app/newrelic/newrelic.jar
#COPY newrelic.jar /opt/app/newrelic/newrelic.jar

RUN mkdir -p /opt/app/newrelic/logs
RUN chmod 777 /opt/app/newrelic/logs

## JAVA_OPTS are being passed via springapp-deployment.yml e.i. -javaagent:/opt/app/newrelic/newrelic.jar -Dnewrelic.config.app_name=Docker-SpringApp -Dnewrelic.config.distributed_tracing.enabled=true
ENTRYPOINT java ${JAVA_OPTS} -jar spring-boot-web.jar


## Build NOTES:
#docker build -t {USERNAME}/springapp:1.0 . --build-arg LICENSE_KEY=${NEW_RELIC_LICENSE_KEY}
#docker push {USERNAME}/springapp:1.0

## Localized run
#docker run -p 8080:8080 -t {USERNAME}/springapp:1.0
