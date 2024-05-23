using GrpcService.Endpoints;
using GrpcService1.Services;
using Microsoft.AspNetCore.Authentication.Certificate;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.AspNetCore.Server.Kestrel.Https;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;

var app = Build(args);
Configure(app);
app.Run();

static WebApplication Build(string[] args)
{
    var builder = WebApplication.CreateBuilder(args);

    builder.Services.Configure<KestrelServerOptions>(options =>
    {
        options.ConfigureHttpsDefaults(options =>
        {
            options.ClientCertificateMode = ClientCertificateMode.RequireCertificate;

            options.ClientCertificateValidation = (cert, chain, policyErrors) =>
            {
                Console.WriteLine("Cert Chain: " + chain?.ChainElements.FirstOrDefault()?.Certificate?.Subject);

                // Fixes http3 errors
                // https://github.com/dotnet/runtime/blob/d54486e40a00e30d5fcad264b73b0ebf0e6941f9/src/libraries/System.Net.Quic/src/System/Net/Quic/QuicConnection.SslConnectionOptions.cs
                // Certificate PolicyErrors (0):RemoteCertificateNameMismatch with status:  for CN=mydomain.com, O=Geocast, L=San Francisco, S=California, C=US
                if (policyErrors.HasFlag(SslPolicyErrors.RemoteCertificateNameMismatch) && (cert.Subject.Contains("CN=mydomain.com") || cert.Subject.Contains("CN=int.mydomain.com")))
                    policyErrors &= ~SslPolicyErrors.RemoteCertificateNameMismatch;

                if (policyErrors != SslPolicyErrors.None)
                {
                    Console.WriteLine($@"Certificate: " + cert.Subject);
                    Console.WriteLine($@"Chain PolicyErrors ({chain?.ChainStatus.Length}):" + policyErrors + " with status: " + chain?.ChainStatus.FirstOrDefault().StatusInformation + " for " + cert.Subject);
                    return false;
                }
                else
                    return true;
            };
        });
    });


    builder.Services.AddAuthentication(CertificateAuthenticationDefaults.AuthenticationScheme)
        .AddCertificate(options =>
        {
            options.AllowedCertificateTypes = CertificateTypes.All;
            options.RevocationMode = X509RevocationMode.NoCheck;
        });

    builder.Services.AddGrpc();

    builder.Configuration
        .SetBasePath(builder.Environment.ContentRootPath)
        .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
        .AddJsonFile($"appsettings.{Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")}.json", optional: true)
        .AddEnvironmentVariables();

    return builder.Build();
}

static void Configure(WebApplication app)
{
    app.UseHttpsRedirection();
    app.UseStaticFiles();
    app.UseCertificateForwarding();
    app.UseAuthentication();

    app.UseForwardedHeaders(new ForwardedHeadersOptions
    {
        ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
    });

    app.UseRouting().UseEndpoints(endpoints =>
    {
        endpoints.MapGrpcService<GreeterService>();
        endpoints.MapGet("/", () => "Communication with gRPC endpoints must be made through a gRPC client. To learn how to create a client, visit: https://go.microsoft.com/fwlink/?linkid=2086909");
    });

    GreetEndpoints.Map(app);
}