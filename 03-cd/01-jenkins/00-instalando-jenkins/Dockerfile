# Warning: Outdated image
# FROM jenkinsci/blueocean:latest

FROM jenkins/jenkins:lts-jdk11

USER root

# install docker-cli
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli

# install docker-compose
RUN curl --fail -sL https://api.github.com/repos/docker/compose/releases/latest| grep tag_name | cut -d '"' -f 4 | tee /tmp/compose-version \
  && mkdir -p /usr/lib/docker/cli-plugins \
  && curl --fail -sL -o /usr/lib/docker/cli-plugins/docker-compose https://github.com/docker/compose/releases/download/$(cat /tmp/compose-version)/docker-compose-$(uname -s)-$(uname -m) \
  && chmod +x /usr/lib/docker/cli-plugins/docker-compose \
  && ln -s /usr/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose \
  && rm /tmp/compose-version

# install node
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
  && apt-get install -y nodejs

USER jenkins

RUN jenkins-plugin-cli --plugins "blueocean:1.25.8 docker-workflow:521.v1a_a_dd2073b_2e"
