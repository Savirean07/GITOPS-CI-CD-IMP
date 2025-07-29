# Use OpenJDK base image
FROM openjdk:17-jdk-slim

# Create app directory
WORKDIR /app

# Copy the built jar file into the image
COPY target/*.jar app.jar

# Expose application port (customize as needed, e.g., 8080)
EXPOSE 8080

# Run the JAR
ENTRYPOINT ["java", "-jar", "app.jar"]
