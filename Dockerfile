# Stage 1: Build the application using Maven
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY . .
# Skip tests to make the build faster on Render's limited resources
RUN mvn clean package -DskipTests

# Stage 2: Run the application
FROM openjdk:17-jdk-slim
WORKDIR /app
# IMPORTANT: Make sure this name matches the <artifactId> and <version> in your pom.xml
# Based on your previous pom.xml, it should be: tickets-0.0.1-SNAPSHOT.jar
COPY --from=build /app/target/tickets-0.0.1-SNAPSHOT.jar app.jar

# Tell the app to use the PORT provided by Render
ENTRYPOINT ["java", "-Xmx512m", "-Dserver.port=${PORT}", "-jar", "app.jar"]