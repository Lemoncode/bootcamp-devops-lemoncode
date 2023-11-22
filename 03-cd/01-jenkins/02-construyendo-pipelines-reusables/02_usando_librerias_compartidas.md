# Demo 2

Usando librerías compartidas `https://github.com/Lemoncode/bootcamp-jenkins-library.git`.

Crear un nuevo repo en GitHub, clonar en local, y crear el siguiente _directorio/fichero_ en el raíz `./vars/auditTools.groovy`

```groovy
def call() { // 2
    node { // 1
        sh '''
            git version
            docker version
            node --version
            npm version
        '''
    }
}
```

- Para que este disponible como parte de una librería compartida tendremos que hacer 3 cosas:
  1. El código tiene que estar envuelto en un bloque _node_
  2. El nombre del método tiene que ser _call_. Ese es el nombre por defecto que _Jenkins_ espera cunado invoque un de los `custom steps`
  3. El nombre del fichero `auditTools.groovy`, coincidirá cone el nombre del paso que queremos utilizar.

Push changes

## Pre-reqs

Ejecutar Jenkins en [Docker](https://www.docker.com/products/docker-desktop):

```bash
$ ./start_jenkins.sh <jenkins-network> <jenkins-image> <jenkins-volume-certs> <jenkins-volume-data>
```

## 2.1 Usando una librería compartida

Crear un nuevo repositorio de git `jenkins-demos-library`

Hemos movido el código de `auditTools` a su propio _script file_.

> Notar que todos los scripts se encuentran dentro del mismo directorio _vars_, y ese es otro requisito. Así que para encontrar estos pasos _custom_ que son parte de la librería tienen que estar en este directorio,

- Crear `02-pipelines/2.1/Jenkinsfile`.

> Debemos apuntar al repositorio correcto

```groovy
library identifier: 'bootcamp-jenkins-library@main',
        retriever: modernSCM([$class: 'GitSCMSource', remote: 'https://github.com/Lemoncode/bootcamp-jenkins-library.git']) // [1]

pipeline {
    agent any
    stages {
        stage('Audit tools') {
            steps {
                auditTools() // [2]
            }
        }
    }
}
```

1. Así es como referenciamos la librería. La primera parte es el _identifier_, que es el nombre del proyecto y la rama del código fuente en _GitHub_. Después Jenkins necesita saber como puede recuperar ese código, eso es lo que hace el bloque _retriever_.

2. Para ejecutarlo necesitamos el nombre del script.

- New item, pipeline, de nombre `02-pipelines-2.1`.
- Copy item, seleccionamos `02-pipelines-1.3`.
- Cambiamos la ruta del Jenkinsfile por `02-pipelines/2.1`.
- Ejecutamos la build. Vemos logs de retrieval de la librería.
- Ejecutamos la build en Blue Ocean. Vemos logs de retrieval de la librería.

## 2.2 Errores en las librerías

> Crear auditTools2.groovy en el repo de librerías

```groovy
def call(Map config) {
    node {
        echo ${config.message}
        sh '''
            git version
            docker version
            node --version
            npm version
        '''
    }
}
```

Una de las cosas a tener en cuenta es el versionado, que puede ser peligroso.

Creamos el siguiente Jenkinsfile `02-pipelines/2.2/Jenkinsfile` en el repo de demos:

```groovy
library identifier: 'jenkins-pipeline-demo-library@main',
        retriever: modernSCM([$class: 'GitSCMSource', remote: 'https://github.com/Lemoncode/bootcamp-jenkins-library.git'])

pipeline {
    agent any
    stages {
        stage('Audit tools') {
            steps {
                auditTools2()
            }
        }
    }
}
```

Desde Jenkins:

- New item, pipeline, de nombre `02-pipelines-2.2`.
- Copy item, seleccionamos `02-pipelines-2.1`.
- Cambiamos la ruta del Jenkinsfile por `02-pipelines/2.2`.
- Ejecutamos la build. Vemos los logs y vemos que falla porque se ha ejecutado sin parámetros.

```
Also:   org.jenkinsci.plugins.workflow.actions.ErrorAction$ErrorId: d2ff85b7-d226-4f63-8b2e-f03e2b887be5
java.lang.NullPointerException: Cannot get property 'message' on null object
```

- Modificamos Jenkinsfile pasándole objeto con propiedades:

```diff
  stage('Audit tools') {
      steps {
-         auditTools2()
+         auditTools2(message: 'This is demo 2.1')
      }
  }
```

- Ejecutamos y vemos el comportamiento.
- Ejecutamos desde BlueOcean.

- Check library method [auditTools2.groovy](../shared-library/vars/auditTools2.groovy)
- Fix quotes & push GitHub repo > `echo "${config.message}"`
- Build again - passes, no change to code or pipeline

## 2.3 Shared libraries en una Build completa

> Crear getVersionSuffix.groovy en el library repo

```groovy
def call(Map config) { // [1]
    node {
        if (config.isReleaseCandidate) { // [2]
            return config.rcNumber // [3]
        } else {
            return config.rcNumber + '+ci' + env.BUILD_NUMBER
        }
    }
}
```

La manera en la que podemos llamar a este script

```groovy
VERSION_SUFFIX = getVersionSuffix rcNumber: env.VERSION_RC, isReleaseCandidate: params.RC
```

1. La manera en la que funcionan los parámetros es que el método toma este objeto map llamado _config_ que puede tener muchos pares clave valor.
2. Dentro está buscando una clave que sea _isReleaseCandidate_, este es un _boolean_, que la `pipeline` alimentará.
3. También espera la clave _rcNumber_

Crear `01/demo2/2.3/Jenkinsfile`, comenzando desde `01/demo1/1.3/Jenkinsfile`

```groovy
library identifier: 'jenkins-pipeline-demo-library@main',
        retriever: modernSCM([$class: 'GitSCMSource', remote: 'https://github.com/Lemoncode/bootcamp-jenkins-library.git'])

pipeline {
    agent any
    parameters {
        booleanParam(name: 'RC', defaultValue: false, description: 'Is this a Release Candidate?')
    }
    environment {
        VERSION = sh([ script: 'cd ./02-pipelines/solution && npx -c \'echo $npm_package_version\'', returnStdout: true ]).trim()
        VERSION_RC = "rc.2"
    }
    stages {
        stage('Audit tools') {
            steps {
                auditTools()
            }
        }
        stage('Build') {
            environment {
                VERSION_SUFFIX = getVersionSuffix(rcNumber: env.VERSION_RC, isReleaseCandidate: params.RC)
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
```

Desde Jenkins:

- New item, pipeline, de nombre `02-pipelines-2.3`.
- Copy item, seleccionamos `02-pipelines-2.2`.
- Cambiamos la ruta del Jenkinsfile por `02-pipelines/2.3`.
- Ejecutamos la build. Vemos los logs.

> Alternative - folder and global libraries

- New item, folder, `01`
- Expand _Pipeline libraries_; implicit load but untrusted

- _Manage Jenkins_ ... _Configure System_
- Expand _Global Pipeline libraries_; implicit load and trusted
