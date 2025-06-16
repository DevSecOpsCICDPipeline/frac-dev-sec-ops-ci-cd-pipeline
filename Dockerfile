
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

# FROM openjdk:21 
# WORKDIR /usr/src/myapp
# COPY .mvn/ .mvn/
# COPY mvnw .
# EXPOSE 8089
# COPY /target/*.war /usr/src/myapp/*.war
# CMD ./mvnw cargo:run
# # CMD ./mvnw cargo:run -P tomcat90

# FROM openjdk:21
# COPY . /usr/src/myapp
# WORKDIR /usr/src/myapp
# RUN ./mvnw clean package
# CMD ./mvnw cargo:run -P tomcat90

FROM tomcat:9.0

# Remove default webapps (optional cleanup)
RUN rm -rf /usr/local/tomcat/webapps/*

# Change the default HTTP connector port from 8080 to 9090
RUN sed -i 's/port="8080"/port="8089"/' /usr/local/tomcat/conf/server.xml

# Copy your WAR
COPY target/*.war /usr/local/tomcat/webapps/

# Expose the new port
EXPOSE 8089