###########################################################################
# https://hub.docker.com/_/microsoft-dotnet-sdk
# - Linux amd64 Tags
# - OS Version Debian 11
###########################################################################

ARG REPO=mcr.microsoft.com/dotnet/aspnet
FROM $REPO:8.0.1-jammy-amd64

ENV \
    # Do not generate certificate
    DOTNET_GENERATE_ASPNET_CERTIFICATE=false \
    # Do not show first run text
    DOTNET_NOLOGO=true \
    # SDK version
    DOTNET_SDK_VERSION=8.0.101 \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip \
    # PowerShell telemetry for docker image usage
    POWERSHELL_DISTRIBUTION_CHANNEL=PSDocker-DotnetSDK-Ubuntu-22.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        cron \
        rsyslog \
        iptables \
        procps \
        curl \
        bash \
        dos2unix \
        build-essential \
        cmake \
        automake \
        libtool \
        autoconf \
        kmod \
        git \
        wget

# Install .NET SDK
RUN curl -fSL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz \
    && dotnet_sha512='26df0151a3a59c4403b52ba0f0df61eaa904110d897be604f19dcaa27d50860c82296733329cb4a3cf20a2c2e518e8f5d5f36dfb7931bf714a45e46b11487c9a' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -oxzf dotnet.tar.gz -C /usr/share/dotnet ./packs ./sdk ./sdk-manifests ./templates ./LICENSE.txt ./ThirdPartyNotices.txt \
    && rm dotnet.tar.gz \
    # Trigger first run experience by running arbitrary cmd
    && dotnet help

# Install PowerShell global tool
RUN powershell_version=7.3.1 \
    && curl -fSL --output PowerShell.Linux.x64.$powershell_version.nupkg https://pwshtool.blob.core.windows.net/tool/$powershell_version/PowerShell.Linux.x64.$powershell_version.nupkg \
    && powershell_sha512='7fad3c38f08e8799e5bd257d8baea6e5fbd3fb81812f66bd6d6b288a091c94aedf4f01613893dabd7763aea8c0116f2feea25808e4b22b2e1e25b3bd8cc5ff1f' \
    && echo "$powershell_sha512  PowerShell.Linux.x64.$powershell_version.nupkg" | sha512sum -c - \
    && mkdir -p /usr/share/powershell \
    && dotnet tool install --add-source / --tool-path /usr/share/powershell --version $powershell_version PowerShell.Linux.x64 \
    && dotnet nuget locals all --clear \
    && rm PowerShell.Linux.x64.$powershell_version.nupkg \
    && ln -s /usr/share/powershell/pwsh /usr/bin/pwsh \
    && chmod 755 /usr/share/powershell/pwsh \
    # To reduce image size, remove the copy nupkg that nuget keeps.
    && find /usr/share/powershell -print | grep -i '.*[.]nupkg$' | xargs rm


##################################################################################################
# Begin Image customization
##################################################################################################

#Install Azure Cli
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Setup http/3
RUN wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get update
RUN apt-get install -y --no-install-recommends libmsquic

WORKDIR /app
COPY . .

# Copy certificates
COPY SSL/Certs/ca.pfx /app/GrpcService
COPY SSL/Certs/int.pfx /app/GrpcService
COPY SSL/Certs/server.pfx /app/GrpcService

COPY SSL/Certs/ca.pfx /app/Http3GrpcUnitTest
COPY SSL/Certs/client.pfx /app/Http3GrpcUnitTest
COPY SSL/Certs/badca.pfx /app/Http3GrpcUnitTest

# Build projects
RUN dotnet restore GrpcService/GrpcService.csproj
RUN dotnet restore Http3GrpcUnitTest/Http3GrpcUnitTest.csproj

WORKDIR /app/GrpcService
RUN dotnet build GrpcService.csproj

WORKDIR /app/Http3GrpcUnitTest
RUN dotnet build Http3GrpcUnitTest.csproj

RUN chmod a+x /app/SSL/hosts.sh

#WORKDIR /app/GrpcService/bin/Debug/net8.0
#ENTRYPOINT ["tail", "-f", "/dev/null"]
#WORKDIR /app/SSL
WORKDIR /app/SSL
ENTRYPOINT ["sh", "hosts.sh"]

