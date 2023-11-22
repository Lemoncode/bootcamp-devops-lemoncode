# Demo 3

Development workflow para pipelines y librerías compartidas.

## Pre-reqs

Ejecutar Jenkins en [Docker](https://www.docker.com/products/docker-desktop):

```bash
$ ./start_jenkins.sh <jenkins-image> <jenkins-network> <jenkins-volume-certs> <jenkins-volume-data>
```

## 3.1 Jenkinsfile Linter

- Crear `02-pipelines/3.1/Jenkinsfile`

```groovy
library identifier: 'jenkins-pipeline-demo-library@main',
        retriever: modernSCM([$class: 'GitSCMSource', remote: 'https://github.com/Lemoncode/bootcamp-jenkins-library.git'])

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
                auditTools()
            }
        }
        stage('Build') {
            environment {
                VERSION_SUFFIX = getVersionSuffix rcNumber: env.VERSION_RC, isReleaseCandidate: params.RC
            }
            steps {
                dir('./01/src') {
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
                dir('./01/src') {
                    sh 'npm test'
                }
            }
        }
        stage('Publish') {
            when {
                expression { return params.RC }
            }
            steps {
                archiveArtifacts('01/src/app/')
            }
        }
    }
}
```

Jenkins API para validar la sintaxis de la pipeline

Nos movemos en el terminal al directorio que contiene el Jenkinsfile al que queremos hacer `lint`. Esto no comprueba que la pipeline 'compila', tan sólo comprueba la sintaxis. Existe una extensión para VSCode, [Jenkins Pipeline Linter Conector](https://marketplace.visualstudio.com/items?itemName=janjoerke.jenkins-pipeline-linter-connector).

> Referencia: https://sandrocirulli.net/how-to-validate-a-jenkinsfile/

```
curl --user lemoncode:lemoncode -X POST -F "jenkinsfile=<./Jenkinsfile" http://localhost:8080/pipeline-model-converter/validate
```

Si ahora metemos un error:

```bash
$ curl --user lemoncode:lemoncode -X POST -F "jenkinsfile=<./Jenkinsfile" http://localhost:8080/pipeline-model-converter/validate
Errors encountered validating Jenkinsfile:
WorkflowScript: 10: expecting ''', found '\n' @ line 10, column 34.
           VERSION = '0.1.0"
```

> Usually need a crumb for CSRF protection

- Catches syntax errors
- Try quote mismatch
- Missing brackets for call
- Doesn't catch missing methods

> VS Code linter integration

- _Extensions_ - search `Jenkinsfile`
- Select _Jenkins Pipeline Linter Connector_
- _F1_ in Jenkinsfile

Related settings:

```json
{
  "jenkins.pipeline.linter.connector.user": "<username>",
  "jenkins.pipeline.linter.connector.url": "http://localhost:8080/pipeline-model-converter/validate",
  "jenkins.pipeline.linter.connector.pass": "<password>"
}
```

## 3.2 Pipeline Replay & Restart

- Open `demo2-2` build 1
- _Restart from stage_ uses original lib
  - Uses exactly the same code and resources, this is useful for CI server connectivity issues.
- _Replay_ allows edit
  - This is useful if you want to repeat your build without changing your `Jenkinsfile` on source control. Obviously when we have fix any trouble that cause the failed we have to go back and change then the `Jenkinsfile`
- Edited replay scripts are preserved in restart
