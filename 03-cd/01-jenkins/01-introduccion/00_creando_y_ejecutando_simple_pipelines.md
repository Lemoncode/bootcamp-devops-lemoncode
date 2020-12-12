# Creando y ejecutando Pipelines simples

## 1.1 Crear una pipeline simple

Log in Jenkins en http://localhost:8080 con `lemoncode`/`lemoncode`.

- New item, pipeline, `demo1-1`
- Select sample pipeline script
- Replace echo with `echo "This is build number $BUILD_NUMBER"`
- Run and check output

```groovy
pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                echo "This is build number $BUILD_NUMBER"
            }
        }
    }
}
```


Si hacemos click en los `logs` podemos encontrar la salida de cada `stage`, el número viene de **$BUILD_NUMBER**, la cual es una variable de entorno que nos provee `Jenkins`.

Como es la primera vez que ejecutamos algo dentro del servidor de Jenkins obtenemos la siguiente salida:

```
Started by user Jaime salas
Running in Durability level: MAX_SURVIVABILITY
[Pipeline] Start of Pipeline
[Pipeline] echo
This is build number 1
[Pipeline] End of Pipeline
[Checks API] No suitable checks publisher found.
Finished: SUCCESS
```

## 1.2 Crear una pipeline simple desde Bitbucket

* Crear un nuevo repositorio en Bitbucket `demo1-2`

Navegamos a http://localhost:8080/blue

- New pipeline `demo1-2`
- Bitbucket repo - git clone https://jaimesalas@bitbucket.org/jaimesalas/demo1-2.git
- Log in with Bitbucket creds

> Needs write access to repo

- Build pipeline
- Add environment variable `DEMO=1`
- Add stage
- Add _Print message_ `This is build $BUILD_NUMBER of demo $DEMO`
- Run and check: doesn't interpolate strings
- View Jenkinsfile in repo:editor only uses single quotes
- Replace with shell script `echo "This is build $BUILD_NUMBER of demo $DEMO"`


Jenkins creates the Jenkinsfile into our new repo, we're not going to get the expected result due to use single quotes.

```groovy
pipeline {
  agent any
  stages {
    stage('stage1') {
      steps {
        echo 'This is the $BUILD_NUMBER of demo $DEMO'
      }
    }

  }
  environment {
    DEMO = '1'
  }
}
```

We add a new step, bash scripting in this case, and commit the new change to master

```groovy
pipeline {
  agent any
  stages {
    stage('stage1') {
      steps {
        echo 'This is the $BUILD_NUMBER of demo $DEMO'
        sh 'echo "This is build $BUILD_NUMBER of demo $DEMO"'
      }
    }

  }
  environment {
    DEMO = '1'
  }
}
```

## 1.3 Crear una Pipeline desde Git

1. Create a new repository on GitHub
2. Add to source control the following code

**./test.sh**

```bash
#!/bin/sh
echo "Inside the script, demo $DEMO"
```

**Jenkinsfile**

```groovy
pipeline {
    agent any

    environment {
        DEMO='1.3'
    }

    stages {
        stage('stage-1') {
            steps {
                echo "This is the build number $BUILD_NUMBER of demo $DEMO"
                sh '''
                   echo "Using a multi-line shell step"
                   chmod +x test.sh
                   ./test.sh 
                '''
            }
        }
    }
}
```

Back in the classic UI http://localhost:8080

- New item, pipeline, `demo1-3`
- Select pipeline from source control
- Git - https://github.com/JaimeSalas/jenkins-pipeline-demos
- Ensure that the source control branch is **main**

> Walk through the [Jenkinsfile](./1.3/Jenkinsfile)

- Run and check 
- Open in blue ocean
- Repeat stage
