# ---- Build stage ----
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# 1) Prime Maven cache with dependencies AND plugins
COPY pom.xml .
RUN mvn -B -U \
    -DskipTests -DskipITs \
    -Dgpg.skip=true \
    dependency:resolve-plugins dependency:go-offline

# 2) Copy sources and build
COPY src ./src
RUN mvn -B -U -e \
    -DskipTests -DskipITs \
    -Dgpg.skip=true \
    clean package

# ---- Runtime stage ----
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
