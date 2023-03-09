## Stage 1 : build ui static content with npm
FROM node:18.14.2 AS build-ui
COPY binstat-ui/angular.json /binstat-ui/angular.json
COPY binstat-ui/package.json /binstat-ui/package.json
COPY binstat-ui/package-lock.json /binstat-ui/package-lock.json
COPY binstat-ui/tsconfig.json /binstat-ui/tsconfig.json
COPY binstat-ui/tsconfig.app.json /binstat-ui/tsconfig.app.json
COPY binstat-ui/tsconfig.spec.json /binstat-ui/tsconfig.spec.json
COPY binstat-ui/src /binstat-ui/src
COPY proto /proto
WORKDIR /binstat-ui
RUN npm install
RUN npm run proto:generate
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

## Stage 3 : create the docker final image with the envoy grpc-web proxy included
FROM envoyproxy/envoy-alpine:v1.21-latest
COPY envoy.yaml /etc/envoy/envoy.yaml
WORKDIR /work/
COPY --from=build /binstat-api/build/*-runner /work/application
COPY launch.sh /work/launch.sh
RUN chmod 775 /work
EXPOSE 8080
ENTRYPOINT ["sh", "./launch.sh"]
