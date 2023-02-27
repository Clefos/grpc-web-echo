package org.acme

import grpc.gateway.Binstat.EchoResponse
import grpc.gateway.Binstat.EchoRequest
import grpc.gateway.EchoServiceGrpc.EchoServiceImplBase
import io.grpc.stub.StreamObserver
import io.quarkus.grpc.GrpcService
import javax.inject.Singleton

@Singleton
@GrpcService
class EchoService: EchoServiceImplBase() {

    override fun echo(request: EchoRequest, responseObserver: StreamObserver<EchoResponse>) {
        val echoMessage = request.message
        val echoResponse = EchoResponse.newBuilder().setMessage(echoMessage).build()
        responseObserver.onNext(echoResponse)
        responseObserver.onCompleted()
    }
}