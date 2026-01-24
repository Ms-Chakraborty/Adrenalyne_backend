# Stage 1: Build the application using Maven
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
# Skip tests to make the build faster on Render
RUN mvn clean package -DskipTests

# Stage 2: Run the application
# We use 'eclipse-temurin' because 'openjdk' is no longer maintained
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Ensure this name matches your pom.xml: <artifactId>-<version>.jar
# Based on your pom.xml, it should be tickets-0.0.1-SNAPSHOT.jar
COPY --from=build /app/target/tickets-0.0.1-SNAPSHOT.jar app.jar

# Tell the app to use the PORT provided by Render
# We also limit memory (Xmx) to fit in Render's Free Tier
ENTRYPOINT ["java", "-Xmx400m", "-Dserver.port=${PORT}", "-jar", "app.jar"]