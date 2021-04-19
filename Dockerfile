FROM maven:3.8.1-jdk-11 as package
WORKDIR application
COPY . .
RUN mvn clean package

FROM adoptopenjdk:11-jre-hotspot as builder
WORKDIR application
#ARG JAR_FILE="--from=package target/*.jar"
COPY --from=package application/target/*.jar application.jar
RUN java -Djarmode=layertools -jar application.jar extract

#FROM adoptopenjdk:11-jre-hotspot
FROM gcr.io/distroless/java:11
WORKDIR application
COPY --from=builder application/dependencies/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
