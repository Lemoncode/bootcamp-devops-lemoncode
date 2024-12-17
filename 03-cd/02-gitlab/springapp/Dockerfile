FROM eclipse-temurin:21.0.5_11-jre
WORKDIR /app
COPY /target/*.jar /app/app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
