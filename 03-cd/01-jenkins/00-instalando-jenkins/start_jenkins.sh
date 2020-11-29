IMAGE=$1
CERTS_VOLUME=$2
DATA_VOLUME=$3

# StartDocker in Docker into jenkins network
docker container run --name jenkins-docker --rm --detach \
    --privileged --network jenkins --network-alias docker \
    --env DOCKER_TLS_CERTDIR=/certs \
    --volume "$CERTS_VOLUME":/certs/client \
    --volume "$DATA_VOLUME":/var/jenkins_home \
    --publish 2376:2376 docker:dind

# Start Jenkins in the same network
docker container run --name jenkins-blueocean --rm --detach \
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --volume "$DATA_VOLUME":/var/jenkins_home \
  --volume "$CERTS_VOLUME":/certs/client:ro \
  --publish 8080:8080 --publish 50000:50000 "$IMAGE"