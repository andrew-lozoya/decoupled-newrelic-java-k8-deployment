## What is it?
This source code is an Spring Boot web application (mvc + thymeleaf).

Tested with
* Docker 18.9-19.03
* Ubuntu 19
* Java 8 or Java 11
* Spring Boot 2.2.4.RELEASE
* Maven

For explanation, please visit this article - [Docker and Spring Boot](https://mkyong.com/docker/docker-spring-boot-examples/)

## Localized
```shell
$ git clone https://github.com/andrewlozoya/decoupled-newrelic-java-k8-deployment
$ cd decoupled-newrelic-java-k8-deployment/docker-spring-boot
$ mvn clean package
$ java -jar target/spring-boot-web.jar
```
access http://localhost:8080

## Docker
```shell
$ sudo docker build -t spring-boot:1.0 .
$ sudo docker push {USERNAME}/springapp:1.0
$ sudo docker run -d -p 8080:8080 -t {USERNAME}/spring-boot:1.0
```
access http://localhost:8080