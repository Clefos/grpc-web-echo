package org.acme.grpc;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;

@Path("/api/echo")
public class EchoController {

    @POST
    @Produces(MediaType.TEXT_PLAIN)
    @Consumes(MediaType.TEXT_PLAIN)
    public String echo(final String echo) {
        return echo;
    }
}
