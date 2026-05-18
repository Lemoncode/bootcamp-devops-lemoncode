FROM jenkins/jenkins:lts-jdk21

USER root

# Install docker-cli
RUN apt-get update && apt-get install -y lsb-release \
  && curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc https://download.docker.com/linux/debian/gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
  && apt-get update && apt-get install -y docker-ce-cli

# Install NodeJS
RUN apt-get update \
  && apt-get install -y ca-certificates curl gnupg \
  && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -  \
  && apt-get install -y nodejs

USER jenkins
