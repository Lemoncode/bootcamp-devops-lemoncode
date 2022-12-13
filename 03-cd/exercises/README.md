# Ejercicios
 
## Ejercios Jenkins
 
### 1. CI/CD de una Java + Gradle
 
En el directorio raíz de este [código fuente](./jenkins-resources), crea un `Jenkinsfile` que contenga un pipeline declarativa con los siguientes stages:
 
* **Checkout** descarga de código desde un repositorio remoto, preferentemente utiliza GitHub.
* **Compile** compilar el código fuente, para ello utilizar `gradlew compileJava`
* **Unit Tests** ejecutar los test unitarios, para ello utilizar `gradlew test`
 
Para ejecutar Jenkins en local y tener las dependencias necesarias disponibles podemos contruir una imagen a partir de [este Dockerfile](./jenkins-resources/gradle.Dockerfile)
 
### 2. Modificar la pipeline para que utilice la imagen Docker de Gradle como build runner

* Utilizar Docker in Docker a la hora de levantar Jenkins para realizar este ejercicio.
* Como plugins deben estar instalados `Docker` y `Docker Pipeline`
* Usar la imagen de Docker `gradle:6.6.1-jre14-openj9`
 
## Ejercicios GitLab
 
### 1. CI/CD de una aplicación spring
 
* Crea un nuevo proyecto en GitLab y un repositorio en el mismo, para la aplicación `springapp`. El código fuente de la misma lo puedes encontrar en este [enlace](../02-gitlab/springapp).
* Sube el código al repositorio recientemente creado en GitLab.
* Crea una pipeline con los siguientes stages:
 * maven:build - En este `stage` el código de la aplicación se compila con [maven](https://maven.apache.org/).
 * maven:test - En este `stage` ejecutamos los tests utilizando [maven](https://maven.apache.org/).
 * docker:build - En este `stage` generamos una nueva imagen de Docker a partir del Dockerfile suministrado en el raíz del proyecto.
 * deploy - En este `stage` utilizamos la imagen anteriormente creada, y la hacemos correr en nuestro local
 
* **Pistas**:
 - Utiliza la versión de maven 3.6.3
 - El comando para realizar una `build` con maven: `mvn clean package`
 - El comando para realizar los tests con maven: `mvn verify`
 - Cuando despleguemos la aplicación en local, podemos comprobar su ejecución en: `http://localhost:8080`
 
En resumen, la `pipeline` de `CI/CD`, debe hacer la build de la aplicación generando los ficheros jar, hacer los tests de maven y finalmente dockerizar la app (el dockerfile ya se proporciona en el repo) y hacer un deploy en local.
 
### 2. Crear un usuario nuevo y probar que no puede acceder al proyecto anteriormente creado
* Añadirlo con el role `guest`, comprobar que acciones puede hacer.
* Cambiar a role `reporter`, comprobar que acciones puede hacer.
* Cambiar a role `developer`, comprobar que acciones puede hacer.
* Cambiar a role `maintainer`, comprobar que acciones puede hacer.
 
* **Nota** (acciones a probar):
 - Commit
 - Ejecutar pipeline manualmente
 - Push and pull del repo
 - Merge request
 - Acceder a la administración del repo
 
### 3. Crear un nuevo repositorio, que contenga una pipeline, que clone otro proyecto, springapp anteriormente creado. Realizarlo de las siguientes maneras:
  
* Con el método de CI job permissions model
   - ¿Qué ocurre si el repo que estoy clonando no estoy cómo miembro?
 > Pista: https://docs.gitlab.com/ee/user/project/new_ci_build_permissions_model.html (Dependent Repositories)
 * Con el método deploy keys
   - Crear deploy key en el repo springapp y poner solo lectura
   - Crear pipeline que usando la deploy key
 > Pista: https://docs.gitlab.com/ee/ci/ssh_keys/
 

## Ejercicios GitHub Actions

### Ejercicio 1. Crea un workflow CI para el proyecto de frontend

Copia el directorio [.start-code/hangman-front](../04-github-actions/.start-code/hangman-front) en el directorio raíz del proyecto. Después crea un nuevo workflow, que se disparé cuando exista una nueva pull request, y que ejecute las siguientes oeraciones:

* Build del proyecto de front
* Ejecutar los unit tests

### Ejercicio 2. Crea un workflow CD para el proyecto de frontend

Crea un nuevo workflow que se dispare manualment y que cree una nueva imagen de Docker y lo publique en el siguiente [registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)


### Ejercicio 3. Crea un workflow que ejecute tests e2e

Crea un workflow que se ejecute de la manera que elijas y que ejecute los tests usando [Docker Compose](https://docs.docker.com/compose/gettingstarted/) o [Cypress action](https://github.com/cypress-io/github-action).
