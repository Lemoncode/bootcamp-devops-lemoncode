# Creando y ejecutando Pipelines simples

## 1.1 Crear una pipeline simple

Accedemos a Jenkins en http://localhost:8080 con `lemoncode`/`lemoncode`.

- New item, de tipo pipeline, con nombre `01-intro-1.1`
- Escribimos el siguiente contenido en la sección Pipeline script:

```groovy
pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                echo "This is the build number $BUILD_NUMBER"
            }
        }
    }
}
```

- Guardamos y lanzamos la build con Build Now. Observar el resultado.

Si hacemos click en los `logs` podemos encontrar la salida de cada `stage`, el número viene de **$BUILD_NUMBER**, la cual es una variable de entorno que nos provee `Jenkins`.

Como es la primera vez que ejecutamos algo dentro del servidor de Jenkins obtenemos la siguiente salida:

```
Started by user Jaime salas
Running in Durability level: MAX_SURVIVABILITY
[Pipeline] Start of Pipeline
[Pipeline] echo
This is the build number 1
[Pipeline] End of Pipeline
[Checks API] No suitable checks publisher found.
Finished: SUCCESS
```

## 1.2 Crear una pipeline simple desde Bitbucket con BlueOcean

- Crear un nuevo repositorio en Bitbucket `jenkins-demos`
- Añadimos el fichero Jenkinsfile con el siguiente contenido:

```groovy
pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                echo 'Hello world'
            }
        }
    }
}
```

Navegamos a http://localhost:8080/blue

- New PipelineNew item, Butbucket Cloud
- Utilizamos nuestro usuario y contraseña. Vemos que no podemos acceder. Necesitamos crear una App Password.
  - Desde Bibucket accedemos Personal Bitbucket Settings usando el icono del engranaje arriba a la derecha.
  - Seleccionamos App password en el menú lateral.
  - Creamos una app password con permisos: Account(Read), Projects(Read), Repositories(Write), Pull requests(Write) y lo llamamos `jenkins-demos`.
- Utilizamos nuestro usuario y la app password generada para autenticarnos.
- Seleccionamos nuestro repositorio, Create Pipeline.

Veremos que la pipeline se ha generado sobre la rama `master`.

Mostrar el resultado desde la interfaz clásica. Este proyecto es un proyecto multi branch.

- Añadimos sección `environment` con la variable `DEMO=1.2`.
- Modificamos el mensaje para que quede `'This is the build $BUILD_NUMBER of demo $DEMO'`.

```diff
  pipeline {
      agent any

      stages {
          stage('stage1') {
              steps {
-                 echo 'Hello world'
+                 echo 'This is the build number $BUILD_NUMBER of demo $DEMO'
              }
          }
      }
+     environment {
+         DEMO = '1'
+     }
  }
```

- Ejecutamos y vemos que no realiza la interpolación.
- Modificamos el fichero Jenkinsfile y pasamos de comillas simples a dobles: `echo "This is the build $BUILD_NUMBER of demo $DEMO"`.
- Ejecutamos y vemos de nuveo que ahora sí están interpoladas.
- Añadiremos un nuevo step `sh` con el mismo contenido del echo.

```diff
  pipeline {
      agent any

      stages {
          stage('stage1') {
              steps {
                  echo "This is the build number $BUILD_NUMBER of demo $DEMO"
+                 sh "echo 'This is the $BUILD_NUMBER of demo $DEMO'"
              }
          }
      }
      environment {
          DEMO = '1'
      }
  }
```

Es importante entender que utilizar el Credentials Provider de BlueOcean está desaconsejado. Aparecerá un warning en la barra superior.

- Eliminaremos nuestro item `01-intro-1.2` y lo recrearemos desde la interfaz clásica.

  - New item, pipeline, 01-intro-1.2`.
  - En la sección Pipeline seleccionamos pipeline script from SCM.
  - Pondremos la URL por HTTPS de nuestro repositorio. Guardamos.
  - Hacemos una build y vemos los logs.

- Crearemos de nuevo el item `01-intro-1.2-multi` como multi branch:

  - New item, Multibranch Pipeline, `01-intro-1.2-multi`.
  - Branch Sources seleccionamos Bitbucket.
  - Añadimos credenciales en el Store de Jenkins.
    - Tipo Username with password.
    - Ponemos nuestro username de Bitbucket y usamos la app password como Password.
    - Añadimos el id `bitbucket-credentials`.
  - Seleccionamos la credencial que acabamos de crear
  - Usamos nuestro nombre de usuario de Bitbucket como Owner.
  - Seleccionamos nuestro repositorio `01-intro-1.2`. Guardamos.
  - Verificamos que la build sobre master se ha hecho.

- Eliminaremos las credenciales de nuestro usuario.
  - Seleccionamos nuestro usuario desde la barra superior, credentials, Store blueoceans-bitbucket-cloud-domain, Delete domain.

Realizar el mismo paso cambiando la visibilidad del proyecto de Bitbucket a `private`.

## 1.3 Crear una Pipeline desde GitHub

- Crear un nuevo repositorio en GitHub `jenkins-demos`. Este repositorio lo utilizaremos para el resto de las demos. Lo haremos privado para añadirle credenciales a Jenkins.
- Añadimos los siguientes ficheros a nuestro repositorio:

**./01-intro/1.1/test.sh**

```bash
#!/bin/sh
echo "Inside the script, demo $DEMO"
```

**./01-intro/1.1/Jenkinsfile**

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

- Creamos el token para utilizarlo como credenciales en GitHub.
  - Seleccionamos nuestro avatar desde la barra superior, Settings
  - Accedemos a Developer settings al final del menú lateral.
  - Seleccionamos Fine-grained tokens. Generate new token.
  - Seleccionamos la fecha de expiración y el nombre. Seleccionamos nuestro nuevo repositorio.
  - Seleccionamos los siguientes permisos: Contents(Write), Commit Status(Write), Pull requests(Write).
  - Generamos token.

Accedemos desde la interfaz clásica de Jenkins http://localhost:8080

- New item, pipeline, `01-intro-1.3`.
- Seleccionamos Pipeline script from SCM
- Seleccionamos Git y añadimos el repo por HTTPS.
- Añadimos la credencial de tipo Username with password. Usaremos el username de GitHub y como Password pondremos nuestro token. Guardamos.
- Seleccionamos nuestra credencial.
- Reemplazamos `master` por `main` en el nombre de la rama.
- Guardamos la pipeline y ejecutamos. Vemos los logs.

Vemos que tenemos un error de que no encuentra los ficheros por no tenerlos en la ruta raíz. Modificamos nuestro Jenkinsfile con una nueva directiva `dir`:

```diff
  stage('stage-1') {
      steps {
+         dir('01-intro/1.1') {
              echo "This is the build number $BUILD_NUMBER of demo $DEMO"
              sh '''
                  echo "Using a multi-line shell step"
                  chmod +x test.sh
                  ./test.sh
              '''
          }
+     }
  }
```

Commiteamos y ejecutamos la build de nuevo.

- Abrimos la interfaz de BlueOcean, ejecutamos y vemos los logs.
