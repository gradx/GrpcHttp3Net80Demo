#!/bin/bash
echo '127.0.0.1  mydomain.com' >> /etc/hosts
echo '127.0.0.1  int.mydomain.com' >> /etc/hosts
echo '127.0.0.1  chained.int.mydomain.com' >> /etc/hosts

openssl pkcs12 -in /app/GrpcService/ca.pfx -nokeys -out /usr/local/share/ca-certificates/mydomain.crt --password pass:""
openssl pkcs12 -in /app/GrpcService/int.pfx -nokeys -out /usr/local/share/ca-certificates/int.crt --password pass:""

update-ca-certificates

cd /app/GrpcService/bin/Debug/net8.0/
dotnet GrpcService.dll &
cd /app/Http3GrpcUnitTest
dotnet test

echo
echo
echo "##################################################"
echo "##### 2 tests are failing on linux & windows #####"
echo "##################################################"
echo
echo "Press enter to exit"

read
