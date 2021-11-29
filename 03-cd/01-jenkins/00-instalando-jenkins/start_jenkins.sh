#!/bin/bash
IMAGE=$1
NETWORK=$2
CERTS_VOLUME=$3
DATA_VOLUME=$4

# Reference: https://forums.docker.com/t/how-to-filter-docker-ps-by-exact-name/2880/3

if [[ ! "$(docker network ls --format '{{.Name}}' --filter name=^${NETWORK}$)" ]]; then
  docker network create $NETWORK
  echo "network jenkins $NETWORK"
fi

if [[ ! "$(docker volume ls --format '{{.Name}}' --filter name=^${CERTS_VOLUME}$)" ]]; then
  docker volume create $CERTS_VOLUME
  echo "jenkins certs $CERTS_VOLUME"
fi

if [[ ! "$(docker volume ls --format '{{.Name}}' --filter name=^${DATA_VOLUME}$)" ]]; then
  docker volume create $DATA_VOLUME
  echo jenkins data "$DATA_VOLUME"
fi

# StartDocker in Docker into jenkins network
docker container run --name jenkins-docker --rm --detach \
    --privileged --network "$NETWORK" --network-alias docker \
    --env DOCKER_TLS_CERTDIR=/certs \
    --volume "$CERTS_VOLUME":/certs/client \
    --volume "$DATA_VOLUME":/var/jenkins_home \
    docker:dind

# Start Jenkins in the same network
docker container run --name jenkins-blueocean --rm --detach \
  --network "$NETWORK" --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --volume "$DATA_VOLUME":/var/jenkins_home \
  --volume "$CERTS_VOLUME":/certs/client:ro \
  --publish 8080:8080 --publish 50000:50000 "$IMAGE"

# Ensure that script have permissions to be executed: chmod +x start_jenkins.sh
# Build image from Dockerfile: docker build -t lemoncode/jenkins .
# From previous image we can run custom Jenkins version as follows:
# ./start_jenkins.sh lemoncode/jenkins jenkins jenkins-docker-certs jenkins-data
