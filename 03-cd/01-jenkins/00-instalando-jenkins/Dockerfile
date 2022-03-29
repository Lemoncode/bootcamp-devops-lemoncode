FROM jenkinsci/blueocean:latest

USER root

# install node
RUN apk add --update nodejs npm

# install docker-compose via python
RUN apk update  \
  && apk add --no-cache python3  \
  && apk add --no-cache --virtual .docker-compose-deps python3 python3-dev py3-pip libffi-dev openssl-dev gcc libc-dev make cargo rust  \
  && pip3 install docker-compose # buildkit

# .NET Core deps
RUN apk add --no-cache \
  ca-certificates \
  icu-libs \
  krb5-libs \
  libgcc \
  libintl \
  libssl1.1 \
  libstdc++ \
  zlib

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT="true" \
  PATH="${PATH}:/root/.dotnet"

# .NET Core SDK
# see https://github.com/dotnet/dotnet-docker/blob/main/src/sdk/3.1/alpine3.14/amd64/Dockerfile
RUN dotnet_sdk_version=3.1.201 \
  && wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-musl-x64.tar.gz \
  && dotnet_sha512='9a8f14be881cacb29452300f39ee66f24e253e2df947f388ad2157114cd3f44eeeb88fae4e3dd1f9687ce47f27d43f2805f9f54694b8523dc9f998b59ae79996' \
  && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
  && mkdir -p /usr/share/dotnet \
  && tar -C /usr/share/dotnet -oxzf dotnet.tar.gz \
  && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
  && rm dotnet.tar.gz \
  # Trigger first run experience by running arbitrary cmd
  && dotnet help

USER jenkins
