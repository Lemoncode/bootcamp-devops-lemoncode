# Demo 1

Clean code - Refactor pipeline

## Pre-req

Ejecutar Jenkins en Docker [Docker](https://www.docker.com/products/docker-desktop)

## 1.1 Una pipeline que comienza a hacer trabajo

Crear un nuevo directorio `02-pipelines`. Copiamos y descomprimimos `code.zip` dentro de `02-pipelines.`:

```bash
$ cd 02-pipelines/
$ unzip code.zip
```

Hacemos `push` de los cambios al repositorio remoto

Creamos `02-pipelines/1.1/Jenkinsfile`

```groovy
pipeline {
    agent any
    environment {
        VERSION = sh([ script: 'cd ./02-pipelines/solution && npx -c \'echo $npm_package_version\'', returnStdout: true ]).trim()
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
                dir('./02-pipelines/solution') {
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
                dir('./02-pipelines/solution') {
                    sh 'npm test'
                }
            }
        }
    }
}
```

Accedemos a Jenkins en http://localhost:8080 con `lemoncode`/`lemoncode`.

- New item, pipeline, de nombre `02-pipelines-1.1`.
- Copy item, seleccionamos `01-intro-1.3`.
- Cambiamos la ruta del Jenkinsfile por `02-pipelines/1.1`.
- Ejecutamos la build y vemos logs.
- Ejecutamos desde Blue Ocean.

## 1.2 Añadiendo parámetros para la build RC

Creamos un Jenkinsfile similar al anterior pero con los siguientes cambios:

```diff
  pipeline {
      agent any
+     parameters {
+         booleanParam(name: 'RC', defaultValue: false, description: 'Is this a Release Candidate?')
+     }
      environment {
          VERSION = sh([ script: 'cd ./02-pipelines/solution && npx -c \'echo $npm_package_version\'', returnStdout: true ]).trim()
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
+             environment {
+                 VERSION_SUFFIX = sh(script:'if [ "${RC}" = "true" ] ; then echo -n "${VERSION_RC}+ci.${BUILD_NUMBER}"; else echo -n "${VERSION_RC}"; fi', returnStdout: true)
+             }
              steps {
                  dir('./02-pipelines/solution') {
-                     echo "Building version ${VERSION} with suffix: ${VERSION_RC}"
+                     echo "Building version ${VERSION} with suffix: ${VERSION_SUFFIX}"
                      sh '''
                          npm install
                          npm run build
                      '''
                  }
              }
          }
          stage('Unit Test') {
              steps {
                  dir('./02-pipelines/solution') {
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
                  archiveArtifacts('02-pipelines/solution/app/')
              }
          }
          /*diff*/
      }
  }
```

Hacemos push de los cambios. Ahora desde Jenkins:

- New item, pipeline, de nombre `02-pipelines-01-1.2`.
- Copy item, seleccionamos `02-pipelines-01-1.1`.
- Cambiamos la ruta del Jenkinsfile por `02-pipelines/01/1.2`.
- Ejecutamos la build y vemos que no hay opción seleccionada. Vemos logs.
- Refrescamos la web de Jenkins. Ahora aparece Build with parameters. Ejecutar sin activar el check, luego activando el check.
- Ejecutamos desde Blue Ocean.

Lo importante que hay que tener en cuenta es este paso condicional que sólo se ejecutará si `RC` vale **true**.

```groovy
stage('Publish') {
    when {
        expression { return params.RC }
    }
    steps {
        archiveArtifacts('02-pipelines/solution/app/')
    }
}
```

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
-               VERSION_SUFFIX = "${sh(script:'if [ "${RC}" = "false" ] ; then echo -n "${VERSION_RC}+ci.${BUILD_NUMBER}"; else echo -n "${VERSION_RC}"; fi', returnStdout: true)}"
+               VERSION_SUFFIX = getVersionSuffix()
            }
            steps {
                dir('./02-pipelines/solution') {
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
                dir('./02-pipelines/solution') {
                    sh 'npm test'
                }
            }
        }
        stage('Publish') {
            when {
                expression { return params.RC }
            }
            steps {
                archiveArtifacts('02-pipelines/solution/app/')
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

Hacemos push de los cambios. Ahora desde Jenkins:

- New item, pipeline, de nombre `02-pipelines-1.3`.
- Copy item, seleccionamos `02-pipelines-1.2`.
- Cambiamos la ruta del Jenkinsfile por `02-pipelines/1.3`.
- Ejecutamos la build y vemos que no hay opción seleccionada. Vemos logs.
- Refrescamos la web de Jenkins. Ahora aparece Build with parameters. Ejecutar sin activar el check, luego activando el check.
- Ejecutamos desde Blue Ocean.
