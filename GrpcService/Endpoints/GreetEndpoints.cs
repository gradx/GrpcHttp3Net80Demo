using Microsoft.AspNetCore.Mvc;

namespace GrpcService.Endpoints
{
    public static class GreetEndpoints
    {
        public static void Map(WebApplication app)
        {
            app.MapGet("api/greet/ping", () =>
            {
                return Results.Content("Pong", "text/html");
            });
        }
    }
}
