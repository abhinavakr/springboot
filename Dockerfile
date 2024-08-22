#stages 1: build with maven
FROM maven:3.8.1-openjdk-17-slim as build
WORKDIR /app
COPY pom.xml .
COPY . .
RUN mvn clean package -Dmaven.test.skip=true
#stages 2: create the final image
FROM FROM eclipse-temurin:21-jdk-alpine
WORKDIR /app
COPY --from=build /app/target/hello.jar .
EXPOSE 8080
CMD ["java", "-jar", "hello.jar"]
