FROM eclipse-temurin:8u392-b08-jre
VOLUME /tmp

ARG JAR_FILE
ADD target/spring-boot-hello-world-1.0.0-SNAPSHOT.jar app.jar

ENV JAR_OPTS=""
ENV JAVA_OPTS=""
ENTRYPOINT exec java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /app.jar $JAR_OPTS
