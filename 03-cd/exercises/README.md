# Ejercicios

## Ejercios Jenkins

### 1. CI/CD de una aplicación NodeJS + TypeScript

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

### 2. Crear un usario nuevo y probar que no puede acceder al proyecto anteriormente creado
  
* Añadirlo con el role `guest`, comprobar que acciones puede hacer.
* Cambiar a role `reporter`, comprobar que acciones puede hacer.
* Cambiar a role `developer`, comprobar que acciones puede hacer.
* Cambiar a role `maintainer`, comprobar que acciones puede hacer.

* **Nota** (acciones a probar):
  - Commit
  - Ejecutar pipeline manualmente
  - Push and pull del repo
  - Merge request
  - Acceder a la administracion del repo

### 3. Crear un nuevo repositorio, que contenga una pipeline, que clone otro proyecto, springapp anteriormente creado. Realizarlo de las siguientes maneras:
    
* Con el método de CI job permissions model
    - ¿Que ocurre si el repo que estoy clonando no estoy cómo miembro?
  
> Pista: https://docs.gitlab.com/ee/user/project/new_ci_build_permissions_model.html (Dependent Repositories)
  
* Con el método deploy keys
    - Crear deploy key en el repo springapp y poner solo lectura
    - Crear pipeline que usando la deploy key
  
> Pista: https://docs.gitlab.com/ee/ci/ssh_keys/

## Ejercicios AzureDevops


