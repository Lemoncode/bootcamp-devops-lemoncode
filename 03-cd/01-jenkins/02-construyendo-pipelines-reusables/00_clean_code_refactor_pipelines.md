# Demo 1

Clean code - Refactor pipeline

## Pre-req

Eliminar las pipelines anteriores

Ejecutar Jenkins en Docker [Docker](https://www.docker.com/products/docker-desktop)

Crear un nuevo directorio _src_tmp/jenkins-demos-review/01_. `unzip` del fichero `01-jenkins/code.zip`

```bash
$ unzip code.zip -d ./src_tmp/jenkins-demos-review/01
```

Hacemos `push` de los cambios al repositorio remoto

Creamos `01/demo1/1.1/Jenkinsfile`

```groovy
pipeline {
    agent any
    environment {
        VERSION = sh([ script: 'cd ./01/solution && npx -c \'echo $npm_package_version\'', returnStdout: true ]).trim()
        VERSION_RC = "rc.2"
    }
    stages {
        stage('Audit tools') {
            steps {
                sh '''
                    git version
                    docker version
                    node --version
                    npm version
                '''
            }
        }
        stage('Build') {
            steps {
                dir('./01/solution') {
                    echo "Building version ${VERSION} with suffix: ${VERSION_RC}"
                    sh '''
                        npm install
                        npm run build
                    '''
                }
            }
        }
        stage('Unit Test') {
            steps {
                dir('./01/solution') {
                    sh 'npm test'
                }
            }
        }
    }
}
```

## 1.1 Una pipeline que comienza a hacer trabajo

Log into Jenkins at http://localhost:8080 with `lemoncode`/`lemoncode`.

- New item, pipeline, `demo1-1`
- Select pipeline from source control
- Git - https://github.com/JaimeSalas/jenkins-pipeline-demos.git https://github.com/Lemoncode/bootcamp-jenkins-demo.git
- Path to Jenkinsfile - `01/demo1/1.1/Jenkinsfile`
- Open in Blue Ocean
- Run

> Walk through the [Jenkinsfile](./1.1/Jenkinsfile)

## 1.2 Añadiendo parámetros para la build RC

```groovy
pipeline {
    agent any
    /*diff*/
    parameters {
        booleanParam(name: 'RC', defaultValue: false, description: 'Is this a Release Candidate?')
    }
    /*diff*/
    environment {
        VERSION = sh([ script: 'cd ./01/solution && npx -c \'echo $npm_package_version\'', returnStdout: true ]).trim()
        VERSION_RC = "rc.2"
    }
    stages {
        stage('Audit tools') {
            steps {
                sh '''
                    git version
                    docker version
                    node --version
                    npm version
                '''
            }
        }
        stage('Build') {
            /*diff*/
            environment {
                VERSION_SUFFIX = sh(script:'if [ "${RC}" == "true" ] ; then echo -n "${VERSION_RC}+ci.${BUILD_NUMBER}"; else echo -n "${VERSION_RC}"; fi', returnStdout: true)
            }
            /*diff*/
            steps {
                dir('./01/solution') {
                    // echo "Building version ${VERSION} with suffix: ${VERSION_RC}"
                    echo "Building version ${VERSION} with suffix: ${VERSION_SUFFIX}"
                    sh '''
                        npm install
                        npm run build
                    '''
                }
            }
        }
        stage('Unit Test') {
            steps {
                dir('./01/solution') {
                    sh 'npm test'
                }
            }
        }
        /*diff*/
        stage('Publish') {
            when {
                expression { return params.RC }
            }
            steps {
                archiveArtifacts('01/solution/app/')
            }
        }
        /*diff*/
    }
}
```

Push changes to remote repository

- Copy item, `demo1-2` from `demo1-1`
- Path to Jenkinsfile `01/demo1/1.2/Jenkinsfile`
- Open in Blue Ocean
- Run (first build doesn't show option)

> Walk through the [Jenkinsfile](./1.2/Jenkinsfile)

Lo importante que hay que tener en cuenta es este paso condicional que sólo se ejecutará si `RC` vale **true**.

```groovy
stage('Publish') {
    when {
        expression { return params.RC }
    }
    steps {
        archiveArtifacts('01/solution/app/')
    }
}
```

- Run again - _RC = no_
- Run again - _RC = yes_

> Check logs and artifacts

## 1.3 Usando métodos de Groovy

Crear `01/demo1/1.3/Jenkinsfile` empezando desde el anterior y editándolo de la siguiente manera:

```diff
pipeline {
    agent any
    parameters {
        booleanParam(name: 'RC', defaultValue: false, description: 'Is this a Release Candidate?')
    }
    environment {
        VERSION = sh([ script: 'cd ./01/solution && npx -c \'echo $npm_package_version\'', returnStdout: true ]).trim()
        VERSION_RC = "rc.2"
    }
    stages {
        stage('Audit tools') {
            steps {
-               sh '''
-                   git version
-                   docker version
-                   node --version
-                   npm version
-               '''
+               auditTools()
            }
        }
        stage('Build') {
            environment {
-               VERSION_SUFFIX = "${sh(script:'if [ "${RC}" == "false" ] ; then echo -n "${VERSION_RC}+ci.${BUILD_NUMBER}"; else echo -n "${VERSION_RC}"; fi', returnStdout: true)}"
+               VERSION_SUFFIX = getVersionSuffix()
            }
            steps {
                dir('./01/solution') {
                    echo "Building version ${VERSION} with suffix: ${VERSION_SUFFIX}"
                    sh '''
                        npm install
                        npm run build
                    '''
                }
            }
        }
        stage('Unit Test') {
            steps {
                dir('./01/solution') {
                    sh 'npm test'
                }
            }
        }
        stage('Publish') {
            when {
                expression { return params.RC }
            }
            steps {
                archiveArtifacts('01/solution/app/')
            }
        }
    }
}
+
+String getVersionSuffix() {
+   if (params.RC) {
+       return env.VERSION_RC
+    } else {
+        return env.VERSION_RC + '+ci' + env.BUILD_NUMBER
+    }
+}
+
+void auditTools() {
+    sh '''
+        git version
+        docker version
+        node --version
+        npm version
+    '''
+}
```

Push changes

- Copy item, `demo1-3` from `demo1-1`
- Path to Jenkinsfile `01/demo1/1.3/Jenkinsfile`
- Build now
- Run

> Walk through the [Jenkinsfile](./1.3/Jenkinsfile)

- Open in Blue Ocean
- Run again - _RC = no_
- Run again - _RC = yes_

> Check logs and artifacts
