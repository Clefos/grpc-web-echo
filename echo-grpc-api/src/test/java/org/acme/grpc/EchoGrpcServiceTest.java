package org.acme.grpc;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.time.Duration;
import java.util.List;

import io.quarkus.grpc.GrpcClient;
import io.quarkus.test.junit.QuarkusTest;

import org.junit.jupiter.api.Assertions;
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

    @Test
    void testStreamingEcho() {
        EchoStreamingRequest echoRequest = EchoStreamingRequest.newBuilder()
                .setMessage("Hello")
                .setFrequency(1)
                .setEchoes(2)
                .build();
        List<String> echoResponses = echoGrpc.echoStreaming(echoRequest)
                .map(EchoResponse::getMessage)
                .collect()
                .asList()
                .await()
                .indefinitely();
        List<String> expected = List.of("Hello", "Hello");
        Assertions.assertIterableEquals(expected, echoResponses);
    }
}
