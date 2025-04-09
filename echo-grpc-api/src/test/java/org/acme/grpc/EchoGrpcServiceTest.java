package org.acme.grpc;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.time.Duration;

import io.quarkus.grpc.GrpcClient;
import io.quarkus.test.junit.QuarkusTest;

import org.junit.jupiter.api.Test;

@QuarkusTest
class EchoGrpcServiceTest {

    @GrpcClient
    EchoService echoGrpc;

    @Test
    void testEcho() {

        EchoRequest echoRequest = EchoRequest.newBuilder()
                .setMessage("Hello")
                .build();
        EchoResponse echoResponse = echoGrpc.echo(echoRequest)
                .await()
                .indefinitely();
        assertEquals(echoRequest.getMessage(), echoResponse.getMessage());
    }

}
