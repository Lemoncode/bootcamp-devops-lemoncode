# Ejercicios

## Ejercicios GitLab

### CI/CD de una aplicación spring

* Crea un nuevo repositorio en GitLab para la aplicación `springapp`, el código fuente de la misma lo puedes encontrar en este [enlace](../02-gitlab/springapp) 

## GitLab

Ejercicios Gitlab

1. Crear APP spring
- Crear repositorio springapp
- Push al repo el contenido de la carpeta springapp proporcionada en github.
- Crear los siguientes stages :
    • maven:build 
    • maven:test
    • docker:build
    • deploy
 Pistas:
    • version maven 3.6.3
    • Comando build de maven → mvn clean package
    • Comando test de maven → mvn verify
    • La url para comprobar la app es http://localhost:8080
    
El pipeline debe hacer el build de la aplicación jar, hacer los tests de maven y finalmente dockerizar la app (el dockerfile ya se proporciona en el repo) y hacer un deploy en local.


2. Crear un usario nuevo y probar que no puede acceder a éste proyecto
    • Añadirlo con el role guest (Comprobar que acciones puede hacer)
    • Cambiar a role reporter  (Comprobar que acciones puede hacer)
    • Cambiar a role developer  (Comprobar que acciones puede hacer)
    • Cambiar a role maintainer  (Comprobar que acciones puede hacer)

Nota:  Cosas a probar
    • Commit
    • Ejecutar pipeline manualmente
    • Push and pull del repo
    • Merge request
    • Acceder a la administracion del repo


3. Crear nuevo repositorio y vamos a hacer un pipeline que lo que haga sea hacer un clone de otro proyecto por ejemplo el springapp. Vamos a realizar de dos maneras:
    • Con el método de CI job permissions model
        ◦ ¿Que ocurre si el repo que estoy clonando no estoy cómo miembro?
      Pista: https://docs.gitlab.com/ee/user/project/new_ci_build_permissions_model.html (Dependent Repositories)
      
    • Con el método deploy keys
        ◦ Crear deploy key en el repo springapp y poner solo lectura
        ◦ Crear pipeline que usando la deploy key
      Pista: https://docs.gitlab.com/ee/ci/ssh_keys/