## Stage 1 : build ui static content with npm
FROM node:18.14.1-alpine AS build-ui
COPY binstat-ui/angular.json /binstat-ui/angular.json
COPY binstat-ui/package.json /binstat-ui/package.json
COPY binstat-ui/tsconfig.json /binstat-ui/tsconfig.json
COPY binstat-ui/tsconfig.app.json /binstat-ui/tsconfig.app.json
COPY binstat-ui/tsconfig.spec.json /binstat-ui/tsconfig.spec.json
WORKDIR /binstat-ui
COPY binstat-ui/src /binstat-ui/src
RUN npm install
RUN npm run build

## Stage 2 : build with gradle builder image with native capabilities
FROM quay.io/quarkus/ubi-quarkus-graalvmce-builder-image:22.3-java17 AS build
USER root
RUN microdnf install findutils
COPY --chown=quarkus:quarkus binstat-api/gradlew /binstat-api/gradlew
COPY --chown=quarkus:quarkus binstat-api/gradle /binstat-api/gradle
COPY --chown=quarkus:quarkus binstat-api/build.gradle.kts /binstat-api/
COPY --chown=quarkus:quarkus binstat-api/settings.gradle.kts /binstat-api/
COPY --chown=quarkus:quarkus binstat-api/gradle.properties /binstat-api/
USER quarkus
WORKDIR /binstat-api
COPY binstat-api/src /binstat-api/src
COPY --from=build-ui binstat-ui/dist/binstat/* /binstat-api/src/main/resources/META-INF/resources/
RUN ./gradlew build -Dquarkus.package.type=native

## Stage 3 : create the docker final image
FROM quay.io/quarkus/quarkus-micro-image:2.0
WORKDIR /work/
COPY --from=build /binstat-api/build/*-runner /work/application
RUN chmod 775 /work
EXPOSE 8080
CMD ["./application", "-Dquarkus.http.host=0.0.0.0"]
