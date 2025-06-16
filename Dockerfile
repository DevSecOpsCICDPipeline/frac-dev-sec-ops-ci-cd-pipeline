
# FROM openjdk:21 AS builder
# COPY . /usr/src/myapp
# WORKDIR /usr/src/myapp
# RUN ./mvnw dependency:go-offline
# RUN ./mvnw clean package  -DskipTests


# FROM openjdk:21-jdk-slim AS final
# WORKDIR /usr/src/myapp
# EXPOSE 8080
# COPY --from=builder /usr/src/myapp/target/*.war /usr/src/myapp/*.war
# CMD ./mvnw cargo:run -P tomcat90

FROM openjdk:21 
WORKDIR /usr/src/myapp
COPY mvnw /usr/src/myapp
EXPOSE 8089
COPY /target/*.war /usr/src/myapp/*.war
CMD ./mvnw cargo:run -P tomcat90