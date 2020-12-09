## Downloading and running Jenkins in Docker

### 1. Create a network for Jenkins

```bash
$ docker network create jenkins
```

### 2. Create the following volumes to share the Docker client TLS certificates needed to connect to the Docker daemon and persist the Jenkins data

```bash
$ docker volume create jenkins-docker-certs
$ docker volume create jenkins-data
```

### 3. In order to execute Docker commands inside Jenkins nodes, download and run the docker:dind Docker image

```bash
docker container run \
    --name jenkins-docker \
    --rm \
    --detach \
    --privileged \
    --network jenkins \
    --network-alias docker \
    --env DOCKER_TLS_CERTDIR=/certs \
    --volume jenkins-docker-certs:/certs/client \
    --volume jenkins-data:/var/jenkins_home \
    --publish 2376:2376 \
    docker:dind
```

#### Commands explanation

```
docker container run \
    --name jenkins-docker \ # 1
    --rm \ # 2
    --detach \ # 3
    --privileged \ # 4
    --network jenkins \ # 5
    --network-alias docker \ # 6
    --env DOCKER_TLS_CERTDIR=/certs \ # 7
    --volume jenkins-docker-certs:/certs/client \ # 8
    --volume jenkins-data:/var/jenkins_home \  # 9
    --publish 2376:2376 \ # 10
    docker:dind # 11
```

1. The Docker container name.
2. Removes the Docker container instance when it is shut down.
3. Runs the Docker container in the background.
4. Running Docker in Docker currently requires privileged access to function properly.
5. Join to previous created network.
6. Makes the Docker in Docker container available as the hostname _docker_ within the _jenkins_ network.
7. Enables the use of TLS in the Docker server. Due to the use of a privileged container, this is recommended, though it requires the use of the shared volume described below. This environment variable controls the root directory where Docker TLS certificates are managed.
8. Maps the _/certs/client_ directory inside the container to a Docker volume named _jenkins-docker-certs_ as created above.
9. Maps the _/var/jenkins_home_ directory inside the container to the Docker volume named _jenkins-data_ as created above. This will allow for other Docker containers controlled by this Docker container's Docker daemon to mount data from Jenkins.
10. Exposes the Docker daemon port on the host machine. This is useful for executing _docker_ commands on the host machine to control this inner Docker daemon.
11. The _docker:dind_ image itself.

### 4. Run jenkins as a container

```bash
docker container run \
    --name jenkins-blueocean \
    --rm \
    --detach \
    --network jenkins \
    --env DOCKER_HOST=tcp://docker:2376 \
    --env DOCKER_CERT_PATH=/certs/client \
    --env DOCKER_TLS_VERIFY=1 \
    --publish 8080:8080 \
    --publish 50000:50000 \
    --volume jenkins-data:/var/jenkins_home \
    --volume jenkins-docker-certs:/certs/client:ro \
    jenkinsci/blueocean
```

#### Commands explanation

```
docker container run \
    --name jenkins-blueocean \ # 1
    --rm \ # 2
    --detach \ # 3
    --network jenkins \ # 4
    --env DOCKER_HOST=tcp://docker:2376 \ # 5
    --env DOCKER_CERT_PATH=/certs/client \
    --env DOCKER_TLS_VERIFY=1 \
    --publish 8080:8080 \ # 6
    --publish 50000:50000 \ # 7
    --volume jenkins-data:/var/jenkins_home \ # 8
    --volume jenkins-docker-certs:/certs/client:ro \ # 9
    jenkinsci/blueocean # 10
```

1. Specifies the Docker container name for this instance of the _jenkinsci/blueocean_ Docker image.

2. Removes the Docker container instance when it is shut down.

3. Runs the Docker container in the background.

4. Connects this container to the jenkins network defined in the earlier step. This makes the Docker daemon from the previous step available to this Jenkins container through the hostname docker.

5. Specifies the environment variables used by `docker`, `docker-compose`, and other Docker tools to connect to the Docker daemon from the previous step.

6. Maps (i.e. "publishes") port 8080 of the _jenkinsci/blueocean_ container to port 8080 on the host machine. The first number represents the port on the host while the last represents the container's port. Therefore, if you specified _-p 49000:8080_ for this option, you would be accessing Jenkins on your host machine through port 49000.

7. Maps port 50000 of the jenkinsci/blueocean container to port 50000 on the host machine. This is only necessary if you have set up one or more inbound Jenkins agents on other machines, which in turn interact with the _jenkinsci/blueocean_ container (the Jenkins "controller"). Inbound Jenkins agents communicate with the Jenkins controller through TCP port 50000 by default. You can change this port number on your Jenkins controller through the Configure Global Security page. If you were to change the TCP port for inbound Jenkins agents of your Jenkins controller to 51000 (for example), then you would need to re-run Jenkins (via this docker run …​ command) and specify this "publish" option with something like _--publish 52000:51000_, where the last value matches this changed value on the Jenkins controller and the first value is the port number on the machine hosting the Jenkins controller. Inbound Jenkins agents communicate with the Jenkins controller on that port (52000 in this example). Note that WebSocket agents in Jenkins 2.217 do not need this configuration.

8. Maps the _/var/jenkins_home_ directory in the container to the Docker volume with the name _jenkins-data_. Instead of mapping the _/var/jenkins_home_ directory to a Docker volume, you could also map this directory to one on your machine's local file system. For example, specifying the option
   _--volume $HOME/jenkins:/var/jenkins_home_ would map the container's _/var/jenkins_home_ directory to the jenkins subdirectory within the _$HOME_ directory on your local machine, which would typically be _/Users/<your-username>/jenkins_ or _/home/<your-username>/jenkins_. Note that if you change the source volume or directory for this, the volume from the _docker:dind_ container above needs to be updated to match this.

9. Maps the _/certs/client_ directory to the previously created _jenkins-docker-certs_ volume. This makes the client TLS certificates needed to connect to the Docker daemon available in the path specified by the _DOCKER_CERT_PATH_ environment variable.

10. The _jenkinsci/blueocean_ Docker image itself.

## Starting Jenkins

To unlock Jenkins we have to paste a password, we can find the password inside the running container, run the following command `cat /var/jenkins_home/secrets/initialAdminPassword` to obtain the initial password

```bash
$ docker container exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword
```

Now install the suggested plugins and wait until Jenkins finishes
