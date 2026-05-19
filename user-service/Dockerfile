# ---- Build Stage ----
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy the POM file first to cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the source code and build the application
COPY src ./src
RUN mvn clean package -DskipTests -B

# ---- Runtime Stage ----
FROM eclipse-temurin:17-jre-alpine

# Create a non‑root user to run the application
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose the default Spring Boot port
EXPOSE 8080

# Set the entry point
ENTRYPOINT ["java", "-jar", "app.jar"]