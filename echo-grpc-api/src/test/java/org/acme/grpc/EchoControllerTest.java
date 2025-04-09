package org.acme.grpc;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;

@QuarkusTest
class EchoControllerTest {

    @Test
    void testHelloEndpoint() {
        given()
        .when()
        .body("echo")
        .post("/api/echo")
        .then()
             .statusCode(200)
             .body(is("echo"));
    }
}