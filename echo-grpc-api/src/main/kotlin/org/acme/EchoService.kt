package org.acme

import org.acme.grpc.EchoResponse
import org.acme.grpc.EchoRequest
import org.acme.grpc.EchoServiceGrpc.EchoServiceImplBase
import io.grpc.stub.StreamObserver
import io.quarkus.grpc.GrpcService
import javax.inject.Singleton

@Singleton
@GrpcService
class EchoService : EchoServiceImplBase() {

    override fun echo(request: EchoRequest, responseObserver: StreamObserver<EchoResponse>) {
        val echoMessage = request.message
        val echoResponse = EchoResponse.newBuilder().setMessage(echoMessage).build()
        responseObserver.onNext(echoResponse)
        responseObserver.onCompleted()
    }
}