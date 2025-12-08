FROM eclipse-temurin:17-jdk

WORKDIR /app

COPY target/*SNAPSHOT.jar app.jar

EXPOSE 8089

ENTRYPOINT ["java", "-jar", "app.jar"]  