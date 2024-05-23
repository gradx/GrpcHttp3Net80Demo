using Grpc.Net.Client;
using GrpcService1;
using System;
using System.Net;
using System.Net.Http;
using System.Threading.Channels;

namespace Http3GrpcUnitTest
{
    public class UnitTest1
    {
        public const string c_SELF_SIGNED_URL = "https://mydomain.com:5001";
        public const string c_CHAINED_URL = "https://int.mydomain.com:5002";

        // gRPC + HTTP3 only always errors
        public const string c_HTTP3_SELF_SIGNED_URL = "https://mydomain.com:5003";
        public const string c_HTTP3_CHAINED_URL = "https://int.mydomain.com:5004";
        

        #region Self Signed Tests
        [Fact]
        public async Task SelfSignedTestHttpVersion20()
        {
            var client = UnitTestHelpers.CreateHttpClient(HttpVersion.Version20, "ca.pfx");
            var result = await UnitTestHelpers.Ping(client, c_SELF_SIGNED_URL);
            Assert.True(result == "Pong");
        }

        [Fact]
        public async Task SelfSignedTestHttpVersion30()
        {
            var client = UnitTestHelpers.CreateHttpClient(HttpVersion.Version30, "ca.pfx");
            var result = await UnitTestHelpers.Ping(client, c_SELF_SIGNED_URL);
            Assert.True(result == "Pong");
        }

        [Fact]
        public async Task SelfSignedTestHttpVersion30Only()
        {
            var client = UnitTestHelpers.CreateHttpClient(HttpVersion.Version30, "ca.pfx");
            var result = await client.GetAsync(c_HTTP3_SELF_SIGNED_URL + "/api/greet/ping");
            var content = await result.Content.ReadAsStringAsync();
            Assert.True(content == "Pong");
        }

        [Fact]
        public async Task SelfSignedTestGrpcHttpVersion30()
        {

            var channel = GrpcChannel.ForAddress(c_SELF_SIGNED_URL,
                new GrpcChannelOptions() { HttpClient = UnitTestHelpers.CreateHttpClient(HttpVersion.Version30, "ca.pfx") });
            var client = new Greeter.GreeterClient(channel);
            var response = await client.SayHelloAsync(new HelloRequest { Name = "World" });
            Assert.True(response.Message == "Hello World");
        }

        [Fact]
        public async Task SelfSignedTestFailureCheck()
        {
            try
            {
                var client = UnitTestHelpers.CreateHttpClient(HttpVersion.Version20, "badca.pfx");
                var result = await client.GetAsync(c_SELF_SIGNED_URL + "/api/greet/ping");
                var content = await result.Content.ReadAsStringAsync();
                Assert.True(content != "Pong");
            }
            catch (System.Net.Http.HttpRequestException)
            {
                return;
            }

            Assert.Fail("Should not reach");
        }

        #endregion

        #region Chained Tests

        [Fact]
        public async Task ChainedTestHttpVersion20()
        {
            var client = UnitTestHelpers.CreateHttpClient(HttpVersion.Version20, "client.pfx");
            var result = await UnitTestHelpers.Ping(client, c_CHAINED_URL);
            Assert.True(result == "Pong");
        }

        [Fact]
        public async Task ChainedTestHttpVersion30()
        {
            var client = UnitTestHelpers.CreateHttpClient(HttpVersion.Version30, "client.pfx");
            var result = await UnitTestHelpers.Ping(client, c_CHAINED_URL);
            Assert.True(result == "Pong");
        }

        [Fact]
        public async Task ChainedTestHttpVersion30Only()
        {
            var client = UnitTestHelpers.CreateHttpClient(HttpVersion.Version30, "client.pfx");
            var result = await UnitTestHelpers.Ping(client, c_HTTP3_CHAINED_URL);
            Assert.True(result == "Pong");
        }

        [Fact]
        public async Task ChainedTestGrpcHttpVersion30()
        {

            var channel = GrpcChannel.ForAddress(c_CHAINED_URL,
                new GrpcChannelOptions() { HttpClient = UnitTestHelpers.CreateHttpClient(HttpVersion.Version30, "client.pfx") });

            var client = new Greeter.GreeterClient(channel);
            var response = await client.SayHelloAsync(new HelloRequest { Name = "World" });
            Assert.True(response.Message == "Hello World");
        }

        [Fact]
        public async Task ChainedTestFailureCheck()
        {
            try
            {
                var client = UnitTestHelpers.CreateHttpClient(HttpVersion.Version20, "badca.pfx");
                var result = await client.GetAsync(c_CHAINED_URL + "/api/greet/ping");
                var content = await result.Content.ReadAsStringAsync();
                Assert.True(content != "Pong");
            }
            catch (System.Net.Http.HttpRequestException)
            {
                return;
            }

            Assert.Fail("Should not reach");
        }

        #endregion

        #region Failing Tests

        // *************************************************************************
        // gRPC + HTTP/3 on Linux/Windows seems to require an Http 1/2 (TCP) upgrade
        // *************************************************************************


        /* Error Message:
        Grpc.Core.RpcException : Status(StatusCode="Unavailable", Detail="Error starting gRPC call. HttpRequestException: Connection refused (mydomain.com:5003) SocketException: Connection refused", DebugException="System.Net.Http.HttpRequestException: Connection refused (mydomain.com:5003)
        ---> System.Net.Sockets.SocketException (111): Connection refused
        at System.Net.Sockets.Socket.AwaitableSocketAsyncEventArgs.ThrowException(SocketError error, CancellationToken cancellationToken)
        at System.Net.Sockets.Socket.AwaitableSocketAsyncEventArgs.System.Threading.Tasks.Sources.IValueTaskSource.GetResult(Int16 token)
        at System.Net.Sockets.Socket.<ConnectAsync>g__WaitForConnectWithCancellation|281_0(AwaitableSocketAsyncEventArgs saea, ValueTask connectTask, CancellationToken cancellationToken)
        at System.Net.Http.HttpConnectionPool.ConnectToTcpHostAsync(String host, Int32 port, HttpRequestMessage initialRequest, Boolean async, CancellationToken cancellationToken)
        --- End of inner exception stack trace ---
        at System.Net.Http.HttpConnectionPool.ConnectToTcpHostAsync(String host, Int32 port, HttpRequestMessage initialRequest, Boolean async, CancellationToken cancellationToken)
        at System.Net.Http.HttpConnectionPool.ConnectAsync(HttpRequestMessage request, Boolean async, CancellationToken cancellationToken)
        at System.Net.Http.HttpConnectionPool.AddHttp2ConnectionAsync(QueueItem queueItem)
        at System.Threading.Tasks.TaskCompletionSourceWithCancellation`1.WaitWithCancellationAsync(CancellationToken cancellationToken)
        at System.Net.Http.HttpConnectionPool.HttpConnectionWaiter`1.WaitForConnectionAsync(Boolean async, CancellationToken requestCancellationToken)
        at System.Net.Http.HttpConnectionPool.SendWithVersionDetectionAndRetryAsync(HttpRequestMessage request, Boolean async, Boolean doRequestAuth, CancellationToken cancellationToken)
        at System.Net.Http.RedirectHandler.SendAsync(HttpRequestMessage request, Boolean async, CancellationToken cancellationToken)
        at System.Net.Http.HttpClient.<SendAsync>g__Core|83_0(HttpRequestMessage request, HttpCompletionOption completionOption, CancellationTokenSource cts, Boolean disposeCts, CancellationTokenSource pendingRequestsCts, CancellationToken originalCancellationToken)
        at Grpc.Net.Client.Internal.GrpcCall`2.RunCall(HttpRequestMessage request, Nullable`1 timeout)")
        Stack Trace:
            at Http3GrpcUnitTest.UnitTest1.GrpcHttpVersion30SelfSignedTest() in /app/Http3GrpcUnitTest/UnitTest1.cs:line 36
        --- End of stack trace from previous location ---*/

        [Fact]
        public async Task Http3OnlyEndpoint_WithGrpcHttp3_IsErroring()
        {
            var channel = GrpcChannel.ForAddress(c_HTTP3_SELF_SIGNED_URL,
                new GrpcChannelOptions() { HttpClient = UnitTestHelpers.CreateHttpClient(HttpVersion.Version30, "ca.pfx") });
            var client = new Greeter.GreeterClient(channel);

            var response = await client.SayHelloAsync(new HelloRequest { Name = "World" });
            Assert.True(response.Message == "Hello World");
        }

        [Fact]
        public async Task Http3OnlyEndpoint_WithGrpcHttp3Chained_IsErroring()
        {
            var channel = GrpcChannel.ForAddress(c_HTTP3_CHAINED_URL,
                new GrpcChannelOptions() { HttpClient = UnitTestHelpers.CreateHttpClient(HttpVersion.Version30, "client.pfx") });
            var client = new Greeter.GreeterClient(channel);

            var response = await client.SayHelloAsync(new HelloRequest { Name = "World" });
            Assert.True(response.Message == "Hello World");
        }

        #endregion
    }
}
