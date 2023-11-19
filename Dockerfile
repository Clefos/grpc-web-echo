## Stage 1 : build ui static content with npm
FROM node:18.14.2 AS build-ui
COPY echo-grpc-web-ui/angular.json /echo-grpc-web-ui/angular.json
COPY echo-grpc-web-ui/package.json /echo-grpc-web-ui/package.json
COPY echo-grpc-web-ui/tsconfig.json /echo-grpc-web-ui/tsconfig.json
COPY echo-grpc-web-ui/tsconfig.app.json /echo-grpc-web-ui/tsconfig.app.json
COPY echo-grpc-web-ui/tsconfig.spec.json /echo-grpc-web-ui/tsconfig.spec.json
COPY echo-grpc-web-ui/src /echo-grpc-web-ui/src
COPY proto /proto
WORKDIR /echo-grpc-web-ui
RUN npm install
RUN npm run proto:generate
RUN npm run build

## Stage 2 : build with gradle builder image with native capabilities
FROM quay.io/quarkus/ubi-quarkus-graalvmce-builder-image:22.3-java17 AS build
USER root
RUN microdnf install findutils
COPY --chown=quarkus:quarkus echo-grpc-api/gradlew /echo-grpc-api/gradlew
COPY --chown=quarkus:quarkus echo-grpc-api/gradle /echo-grpc-api/gradle
COPY --chown=quarkus:quarkus echo-grpc-api/build.gradle.kts /echo-grpc-api/
COPY --chown=quarkus:quarkus echo-grpc-api/settings.gradle.kts /echo-grpc-api/
COPY --chown=quarkus:quarkus echo-grpc-api/gradle.properties /echo-grpc-api/
USER quarkus
WORKDIR /echo-grpc-api
COPY echo-grpc-api/src /echo-grpc-api/src
COPY --from=build-ui echo-grpc-web-ui/dist/echo-grpc-web-ui/* /echo-grpc-api/src/main/resources/META-INF/resources/
RUN ./gradlew build -Dquarkus.package.type=native

## Stage 3 : create the docker final image with the envoy grpc-web proxy included
FROM envoyproxy/envoy-alpine:v1.21-latest
COPY envoy.yaml /etc/envoy/envoy.yaml
WORKDIR /work/
COPY --from=build /echo-grpc-api/build/*-runner /work/application
COPY launch.sh /work/launch.sh
RUN chmod 775 /work
EXPOSE 8080
ENTRYPOINT ["sh", "./launch.sh"]
