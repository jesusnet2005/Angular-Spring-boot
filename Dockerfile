# Multi-stage Dockerfile for Spring Boot (build with Maven, run on JDK 17)

# --- Build stage ---
FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /app

# Copy wrapper and project files
COPY .mvn .mvn
COPY mvnw mvnw
COPY pom.xml pom.xml
COPY src src

# Ensure the wrapper is executable and build
RUN chmod +x mvnw && ./mvnw -B clean package -DskipTests

# --- Run stage ---
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Copy artifact from build stage
COPY --from=build /app/target/*.jar /app/app.jar

# Expose default port
EXPOSE 8080

# Allow Render or other platforms to override Java options and PORT
ENV JAVA_OPTS=""

# Use the environment PORT if provided (Render sets PORT), default to 8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dserver.port=${PORT:-8080} -jar /app/app.jar"]
