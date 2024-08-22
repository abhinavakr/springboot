# Stage 1: Build with Maven
FROM maven:3.9.4-openjdk-21 AS build
WORKDIR /app

# Install Git (if needed for your project)
RUN apt-get update && apt-get install -y git

# Copy the pom.xml file and project source code
COPY pom.xml .
COPY . .

# Build the project with verbose output for debugging
RUN mvn clean package -DskipTests -X

# Stage 2: Create the final image
FROM eclipse-temurin:21-jdk-alpine
WORKDIR /app

# Copy the JAR file from the build stage
COPY --from=build /app/target/hello.jar .

# Expose the port on which the application will run
EXPOSE 8080

# Command to run the application
CMD ["java", "-jar", "hello.jar"]
