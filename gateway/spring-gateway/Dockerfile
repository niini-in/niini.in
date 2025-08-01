FROM maven:3.8.7-openjdk-18-slim AS build

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

FROM openjdk:17-jdk-slim

WORKDIR /app

COPY --from=build /app/target/spring-gateway-*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]