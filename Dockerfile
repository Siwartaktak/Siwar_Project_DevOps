# Use an official OpenJDK runtime as a parent image
FROM openjdk:17-jdk

# Set the working directory in the container
WORKDIR /app

# Copy the jar file built by Maven
COPY target/student-management.jar app.jar

# Expose the port your Spring Boot app runs on
EXPOSE 8089

# Run the jar file
ENTRYPOINT ["java", "-jar", "/app.jar"]
