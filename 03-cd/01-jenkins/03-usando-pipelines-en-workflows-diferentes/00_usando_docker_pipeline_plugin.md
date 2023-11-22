# Demo 1

Corriendo pipelines con Docker.

## Pre-reqs

Ejecutar Jenkins en [Docker](https://www.docker.com/products/docker-desktop):

```bash
$ ./start_jenkins.sh <jenkins-image> <jenkins-network> <jenkins-volume-certs> <jenkins-volume-data>
```

Antes de comenzar borrar las pipelines anteriores

## 1.1 Usando un contenedor como build agent

Create a new directory _05_declarative_pipelines/src_tmp/jenkins-demos-review/02_. Unzip code from `05_declarative_pipelines` directory

```bash
$ unzip code.zip -d ./src_temp/jenkins-demos-review/02
```

Create `03-docker/1.1/Jenkinsfile`

```groovy
pipeline {
    agent {
        docker {
            image 'node:alpine3.12'
        }
    }
    stages {
        stage('Verify') {
            steps {
                sh '''
                  node --version
                  npm version
                '''
                sh 'printenv'
                sh 'ls -l "$WORKSPACE"'
            }
        }
        stage('Build') {
            steps {
                dir("$WORKSPACE/02/solution") {
                    sh '''
                      npm install
                      npm run build
                    '''
                }
            }
        }
        stage('Unit Test') {
            steps {
              dir("$WORKSPACE/02/solution") {
                sh 'npm test'
              }
            }
        }
    }
}
```

Log into Jenkins at http://localhost:8080 with `lemoncode`/`lemoncode`.

- New item, pipeline, `demo1-1`
- Select pipeline from source control
- Git - https://github.com/JaimeSalas/jenkins-pipeline-demos
- Path to Jenkinsfile - `02/demo1/1.1/Jenkinsfile`
- Run

> Walk through the [Jenkinsfile](./02/demo1/1.1/Jenkinsfile)

```groovy
agent {
    docker {
        image 'node:alpine3.12'
    }
}
```

Esta parte es ahora diferente, estamos especificando que el agente es un `contenedor de Docker`, y la imagen `node:alpine3.12` es la que queremos usar. Lo que ocurre cuando esta build arranca, Jenkins arranca un contenedor utilizando como base esta imagen.

Todos los `shell commands` son ejecutados dentro del contenedor.

Puedo usar `Docker` como mi agente de build , y no necesito tener una máquina con `node` instalado. Cualquier servidor de Jenkins, con `Docker` instalado puede levantar una agente con `node` y ejecutar toda la pipeline dentro del contenedor, con Jenkins tomando la responsabilidad de mover los ficheros necesarios y estableciendo el entorno del contenedor por mi.

## 1.2 Custom container agents

- Crear `02/Dockerfile`

```Dockerfile
FROM node:alpine3.12 as builder

WORKDIR /build

COPY ./src .

RUN npm install

RUN npm run build

FROM node:alpine3.12 as application

WORKDIR /opt/app

COPY ./src/package.json .

COPY ./src/package-lock.json .

COPY --from=builder /build/app .

RUN npm i --only=production

ENTRYPOINT ["node", "app.js"]
```

- Create `02/demo1/1.2/Jenkinsfile`

```groovy
pipeline {
    agent {
        dockerfile {
            dir '02/solution'
        }
    }
    stages {
        stage('Verify') {
            steps {
                sh'''
                    node --version
                    npm version
                '''
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t jaimesalas/jenkins-pipeline-demos:0.0.1 .'
            }
        }
        stage('Smoke Test') {
            steps {
                sh 'docker run jaimesalas/jenkins-pipeline-demos:0.0.1'
            }
        }
    }
}
```

Push changes

- Copy item, `demo1-2` from `demo1-1`
- Path to Jenkinsfile `02/demo1/1.2/Jenkinsfile`
- Run - fails

> Walk through the [Dockerfile](../Dockerfile) and the [Jenkinsfile](./02/demo1/1.2/Jenkinsfile)

```groovy
pipeline {
    agent {
        dockerfile {
            dir '02/solution'
        }
    }
    stages {
        stage('Verify') {
            steps {
                sh'''
                    node --version
                    npm version
                '''
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t jaimesalas/jenkins-pipeline-demos:0.0.1 .'
            }
        }
        stage('Smoke Test') {
            steps {
                sh 'docker run jaimesalas/jenkins-pipeline-demos:0.0.1'
            }
        }
    }
}
```

1. En el `agent block` estamos especificando un `Dockerfile`, le estamos diciendo a Jenkins que es un Dockerfile dentro de nuestro repo, en el directorio `02`, y quiero construir una imagen a partir de ese `Dockerfile`. Si inspeccionamos este `Dockerfile` nos damos cuenta de que se trata de una imagen para construir una aplicación, y Jenkins no esta esperando esto.

But what people often do when they're looking at this approach is they get confused as to what that `Dockerfile` is meant to do. So if I look at that `Dockerfile`, this `Dockerfile` is actually a full build of my project.

Esto crea confusión acerca de que hace este `Dockerfile`. Este `Dockerfile` es la `build` completa de mi proyecto.

Comienza desde `node:alpine3.12` e instala los paquetes y realiza una build. Después empaquete la aplicación instalando sólo las dependencias de producción, creando una imagen de Docker que representa nuestra aplicación. Y esto no es lo que espera Jenkins. Cuando Jenkins nos ofrece la opción de fichero Docker, dentro del agente arranca una imagen para ser usada como `build agent` no correr la aplicación.

En esta pipeline estamos pensando que pedimos a Jenkins que compile la aplicación, usando el `Dockerfile` en el repositorio, y después usar `verify` para imprimir node y npm y por último ejecutar un smoke test ejecutando el contenedor previamente generado.

Pero esto son cosas separadas, la imagen construida como parte del `Dockerfile`, sirve para ejecutar la aplicación, no como entorno para construir la misma.

La build falla como esperábamos, echemos un ojo. Podemos ver todas las líneas ejecutadas del `Dockerfile`, y después vemos este mensaje que nos dice que tenemos un fallo al intentar ejecutar el contenedor.

```
[Pipeline] withDockerContainer
Jenkins seems to be running inside container c61967b546156925d074ad58416a569ad9155a1826bd597e25ca2574401b0462
but /var/jenkins_home/workspace/demo1-2 could not be found among []
but /var/jenkins_home/workspace/demo1-2@tmp could not be found among []
$ docker run -t -d -u 1000:1000 -w /var/jenkins_home/workspace/demo1-2 -v /var/jenkins_home/workspace/demo1-2:/var/jenkins_home/workspace/demo1-2:rw,z -v /var/jenkins_home/workspace/demo1-2@tmp:/var/jenkins_home/workspace/demo1-2@tmp:rw,z -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** f917174c9fbddb13d878ba8d5720b4002083488f cat
$ docker top 22e164faebd0bffd3ffa850e62353e97099aef48d4d4fa1616622e45957f8825 -eo pid,comm
[Pipeline] // withDockerContainer
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
[Checks API] No suitable checks publisher found.
java.io.IOException: Failed to run top '22e164faebd0bffd3ffa850e62353e97099aef48d4d4fa1616622e45957f8825'. Error: Error response from daemon: Container 22e164faebd0bffd3ffa850e62353e97099aef48d4d4fa1616622e45957f8825 is not running
```

La razón por la que falla es que Jenkins está tratando de ejecutar el contenedor como un `build agent` pero el contenedor ha sido empaquetado para ejecutar mi aplicación, así que no existe ningún `build agent`.

> Walk through the fixed [Dockerfile.node](../Dockerfile.node) and [Jenkinsfile.fixed](./1.2/Jenkinsfile.fixed)

- Crear `Dockerfile.node`

```Dockerfile
FROM node:alpine3.12 as builder

ENV LEMONCODE_VAR=lemon
```

- Y creamos `02/demo1/1.2/Jenkinsfile.fixed` de la siguiente manera:

```groovy
pipeline {
    agent {
        dockerfile {
            dir '02/solution'
            filename 'Dockerfile.node'
        }
    }
    stages {
        stage('Verify') {
            steps {
                sh '''
                  node --version
                  npm version
                '''
                sh 'printenv'
                sh 'ls -l "$WORKSPACE"'
            }
        }
        stage('Build') {
            steps {
                dir("$WORKSPACE/02/solution") {
                    sh '''
                        npm install
                        npm build
                    '''
                }
            }
        }
        stage('Unit Test') {
            steps {
                dir("$WORKSPACE/02/solution") {
                sh 'npm test'
              }
            }
        }
    }
}
```

```groovy
agent {
    dockerfile {
        dir '02/solution'
        filename 'Dockerfile.node' // [1]
    }
}
```

1. Este `Dockerfile` sirve para personalizar el entorno de build, por ejemplo aquí lo hemos utilizado para incluir una variable nueva de entorno.

- Change Jenkinsfile to `02/demo1/1.2/Jenkinsfile.fixed`
- Run again

## 1.3 Docker pipeline plugin

- Crear `02/demo1/1.3/Jenkinsfile`

```groovy
def image

pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    image = docker.build("jaimesalas/jenkins-pipeline-demos:0.0.1", "--pull -f 02/solution/Dockerfile 02/solution")
                }
            }
        }
        stage('Smoke Test') {
            steps {
                script {
                    container = image.run()
                    container.stop()
                }
            }
        }
        stage('Push') {
            steps {
                script {
                    withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                        image.push()
                    }
                }
            }
        }
    }
}
```

- Credentials in Jenkins - Docker Hub
- Copy item, `demo1-3` from `demo1-1`
- Path to Jenkinsfile `02/demo1/1.3/Jenkinsfile`
- Run

> Walk through the [Jenkinsfile](.02/demo1/1.3/Jenkinsfile) and [Dockerfile](../Dockerfile)

```groovy
def image

pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    image = docker.build("jaimesalas/jenkins-pipeline-demos:0.0.1", "--pull -f 02/Dockerfile 02") // [1]
                }
            }
        }
        stage('Smoke Test') {
            steps {
                script {
                    container = image.run() // [2]
                    container.stop()
                }
            }
        }
        stage('Push') {
            steps {
                script {
                    withDockerRegistry([credentialsId: "docker-hub", url: ""]) { // [3]
                        image.push()
                    }
                }
            }
        }
    }
}
```

Aquí estamos usando `Docker Pipeline plug-in` que nos da un gran control sobre la interacción de `Jenkins` y el `Docker engine`.

1. Usamos el objeto `docker` el cuál es parte de `Docker Pipeline plug-in`, y ejecutamos el método `build`, diciendo el nombre de la imagen de Docker y donde encontrar el `Dockerfile`
2. Ejecutamos un contenedor generado a partir del paso previo.
3. En el último paso publicamos esa imagen

## Adding Jenkins credentials

> https://www.jenkins.io/doc/book/using/using-credentials/#:~:text=From%20the%20Jenkins%20home%20page,Add%20Credentials%20on%20the%20left.
> https://appfleet.com/blog/building-docker-images-to-docker-hub-using-jenkins-pipelines/#:~:text=On%20Jenkins%20you%20need%20to,this%20credential%20from%20your%20scripts.
