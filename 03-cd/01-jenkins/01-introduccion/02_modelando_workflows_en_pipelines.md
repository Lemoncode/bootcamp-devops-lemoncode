# Modelando workflows en las pipelines

## 2.1 Una pipeline multi-stage

- Crear un nuevo Jenkinsfile en `01-intro/2.1/Jenkinsfile`

```groovy
pipeline {
    agent any
    environment {
        RELEASE='0.0.1'
    }
    stages {
        stage('Build') {
            agent any
            environment {
                LOG_LEVEL='INFO'
            }
            steps {
                echo "Building release ${RELEASE} with log level ${LOG_LEVEL}..."
            }
        }
        stage('Test') {
            steps {
                echo "Testing. I can see release ${RELEASE}, but not log level ${LOG_LEVEL}"
            }
        }
    }
}
```

Accedemos a Jenkins en http://localhost:8080 con `lemoncode`/`lemoncode`.

- New item, pipeline, `01-intro-2.1`
- Seleccionamos Pipeline script from SCM
- Seleccionamos Git y añadimos el repo de GitHub con HTTPS.
- Usamos las credenciales de GitHub.
- Reemplazamos `master` por `main` en el nombre de la rama.
- Modificamos la ruta del Jenkinsfile por `01-intro/2.1/Jenkinsfile`
- Ejecutamos y vemos los logs.
- Falla debido a que el step del segundo stage utiliza una variable de entorno desconocida `LOG_LEVEL`.

```
[Checks API] No suitable checks publisher found.
groovy.lang.MissingPropertyException: No such property: LOG_LEVEL for class: groovy.lang.Binding
	at groovy.lang.Binding.getVariable(Binding.java:63)
```

## 2.2 Solicitando el input del Usuario

- Crear un nuevo Jenkinsfile en `01-intro/2.2/Jenkinsfile`:

```groovy
pipeline {
    agent any
    environment {
        RELEASE='0.0.1'
    }
    stages {
        stage('Build') {
            agent any
            environment {
                LOG_LEVEL='INFO'
            }
            steps {
                echo "Building release ${RELEASE} with log level ${LOG_LEVEL}..."
            }
        }
        stage('Test') {
            steps {
                echo "Testing release ${RELEASE}..."
            }
        }
        stage('Deploy') {
            input {
                message 'Deploy?'
                ok 'Do it!'
                parameters {
                    string(name: 'TARGET_ENVIRONMENT', defaultValue: 'PROD', description: 'Target deployment environment')
                }
            }
            steps {
                echo "Deploying release ${RELEASE} to environment ${TARGET_ENVIRONMENT}"
            }
        }
    }
    post {
        always {
            echo 'Prints wether deploy happened or not, success or failure'
        }
    }
}
```

Volvemos a Jenkins http://localhost:8080

- New item, pipeline, de nombre `01-intro-2.2`.
- Copy item, seleccionamos `01-intro-2.1`.
- Cambiamos la ruta del Jenkinsfile por `01-intro/2.2`.

```groovy
input {
    message 'Deploy?'
    ok 'Do it!'
    parameters {
        string(name: 'TARGET_ENVIRONMENT', defaultValue: 'PROD', description: 'Target deployment environment')
    }
}
steps {
    echo "Deploying release ${RELEASE} to environment ${TARGET_ENVIRONMENT}"
}
```

Este paso solicitará una entrada del usuario. Notar que en el siguiente `stage`, podemos acceder a _TARGET_ENVIRONMENT_. Si seleccionamos _abort_ los pasos siguientes no se realizarán.

```
post {
    always {
        echo 'Prints wether deploy happened or not, success or failure'
    }
}
```

En el comando _post_ podemos tener diferentes condiciones aquí estamos usando _always_

- Ejecutamos la build.
- Abre la Console de la build actual, la pipeline queda pausada esperando la entrada del usuario.
- Click en el enlace Input requested
- Post se ejecuta todo el rato

## 2.3 Parallel stages

- Crear un nuevo Jenkinsfile en `01-intro/2.3/Jenkinsfile` en el repo.

```groovy
pipeline {
    agent any
    environment {
        RELEASE='0.0.1'
    }
    stages {
        stage('Build') {
            environment {
                LOG_LEVEL='INFO'
            }
            parallel {
                stage('linux-arm64') {
                    steps {
                        echo "Building release ${RELEASE} for ${STAGE_NAME} with log level ${LOG_LEVEL}..."
                    }
                }
                stage('linux-amd64') {
                    steps {
                        echo "Building release ${RELEASE} for ${STAGE_NAME} with log level ${LOG_LEVEL}..."
                    }
                }
                stage('windows-amd64') {
                    steps {
                        echo "Building release ${RELEASE} for ${STAGE_NAME} with log level ${LOG_LEVEL}..."
                    }
                }
            }
        }
        stage('Test') {
            steps {
                echo "Testing release ${RELEASE}..."
            }
        }
        stage('Deploy') {
            input {
                message 'Deploy?'
                ok 'Do it!'
                parameters {
                    string(name: 'TARGET_ENVIRONMENT', defaultValue: 'PROD', description: 'Target deployment environment')
                }
            }
            steps {
                echo "Deploying release ${RELEASE} to environment ${TARGET_ENVIRONMENT}"
            }
        }
    }
    post {
        always {
            echo 'Prints wether deploy happened or not, success or failure'
        }
    }
}
```

Volver a Jenkins via http://localhost:8080

- New item, pipeline, de nombre `01-intro-2.3`.
- Copy item, seleccionamos `01-intro-2.2`.
- Cambiamos la ruta del Jenkinsfile por `01-intro/2.3`.

```groovy
parallel {
    stage('linux-arm64') {
        steps {
            echo "Building release ${RELEASE} for ${STAGE_NAME} with log level ${LOG_LEVEL}..."
        }
    }
    stage('linux-amd64') {
        steps {
            echo "Building release ${RELEASE} for ${STAGE_NAME} with log level ${LOG_LEVEL}..."
        }
    }
    stage('windows-amd64') {
        steps {
            echo "Building release ${RELEASE} for ${STAGE_NAME} with log level ${LOG_LEVEL}..."
        }
    }
}
```

Con _parallel_ podemos ejecutar múltiples `stages` en paralelo.

- Ejecutamos y vemos los logs.
- Los stages en paralelo se completan en cualquier orden.
- Luego se pausa en el input y finalmente hace el post.
