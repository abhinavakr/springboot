# Stage 1: Build with Maven
FROM maven:3.8.1-openjdk-17-slim AS build
WORKDIR /app

# Copy the pom.xml file and project source code
COPY pom.xml .
COPY . .

# Build the project
RUN mvn clean package -DskipTests

# Stage 2: Create the final image
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app

# Copy the JAR file from the build stage
COPY --from=build /app/target/hello.jar .

# Expose the port on which the application will run
EXPOSE 8080

# Command to run the application
CMD ["java", "-jar", "hello.jar"]
