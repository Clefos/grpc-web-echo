package org.acme.grpc;

import io.grpc.stub.StreamObserver;
import io.quarkus.grpc.GrpcService;
import io.smallrye.mutiny.Multi;

import java.time.Duration;


@GrpcService
public class EchoGrpcService extends EchoServiceGrpc.EchoServiceImplBase {

    @Override
    public void echo(EchoRequest request, StreamObserver<EchoResponse> responseObserver) {
        final String response = request.getMessage();
        final EchoResponse echoResponse = EchoResponse.newBuilder()
                .setMessage(response)
                .build();
        responseObserver.onNext(echoResponse);
        responseObserver.onCompleted();
    }

    @Override
    public void echoStreaming(EchoStreamingRequest request, StreamObserver<EchoResponse> responseObserver) {
        final String response =  request.getMessage();
        final int frequency = request.getFrequency();
        final int echoes = request.getEchoes();

        final EchoResponse echoResponse = EchoResponse.newBuilder()
                .setMessage(response)
                .build();
        Multi.createFrom()
                .ticks()
                .every(Duration.ofSeconds(frequency))
                .select()
                .first(echoes)
                .onItem()
                .invoke(() -> responseObserver.onNext(echoResponse))
                .onCompletion()
                .invoke(() -> responseObserver.onCompleted())
                .toHotStream();
    }
}
