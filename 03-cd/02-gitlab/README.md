# GitLab BOOTCAMP
![](https://about.gitlab.com/images/press/logo/jpg/gitlab-logo-gray-rgb.jpg)

> El entorno está preparado para funcionar tanto en docker(Recomendado) en local o con una maquina virtual vagrant
## Versiones de software
- Vagrant: >= 2.2.x
- Docker Engine: >= 19
- [Docker Compose >= 1.27.4](https://docs.docker.com/compose/install/)
- VirtualBox >= 6.x

## Creación del entorno
1. Permitimos registry inseguro a docker
* En Linux En el fichero /etc/docker/dameon.json
```
{
insecure-registries : [gitlab.local:5001]
}
```
* En windows lo hacemos via Docker Desktop

2a. Preparando el entorno con docker(Linux y windows). 
>> Es necesario permisos sudo (Linux) o Administrador(Windows)
```bash
user@localhost:~$ cd 02-gitlab/02-gitlab/itlab/docker/
user@localhost:~02-gitlab/gitlab/docker$ docker-compose up -d
```
2b. Preparando el entorno con Vagrant y Virtualbox
```bash
user@localhost:~$ cd 02-gitlab/
user@localhost:~02-gitlab/$ vagrant up
```
3. Añadimos entrada al fichero hosts la entrada -> <Direccion_ip_local> gitlab.local"
* Linux en el fichero /etc/hosts 
* Windows en el fichero c:\windows\system32\drivers\etc\hosts 


## Enlaces de docuemntación necesaria
- [¿Què es gitlab?](https://about.gitlab.com/)
- [Un poco de arquitectura](https://docs.gitlab.com/ee/development/img/architecture_simplified.png)

## ¿Qué vamos a aprender?
- Gestion de Usuarios
- Gestión de proyectos(repositorios)
- Entiendo los pipelines
- Creacion de pipelines de build,test y deploy
- Variables predefinidas de gitlab y custom
- Uso de container registry
- Pipelines de creación de imagenes Base
- Usar nuestras Imágenes

## Cheatsheet
### [Variables Predefinidas](https://docs.gitlab.com/ee/ci/variables/predefined_variables.html)
### [Referencia configuración de pipeline](https://docs.gitlab.com/ce/ci/yaml/)

## Guía de Clase
1. Nuestro primer acceso con Gitlab
2. Damos de alta un usuario sin role de administrador
3. Creamos nuestro primer grupo para contener los proyectos de la bootcamp
4. Creamos nuestro primer repositorio hola_mundo con el user creado
5. Validamos que con user2 no podemos acceder y le damos permisos de developer
6. Con user1(owner) creamos nuestro primer pipeline en el repositorio hola_mundo
- Creamos el branch developer
- ¿Cuando se ejecuta un pipeline? ¿Un commit, un merge, manual? ¿y en que branch? ¿AutoDevOps? Vaya lio!
- Estructura básica de un pipeline con Hola Mundo
- Mostrando las variables predefinidias
- Control sobre que branch se ejecuta cada job
- ¿y si falla un job? ¿Se puede puede omitir el fallo?
- ¿y un Environment qué es? ¿Para que sirve?
- ¿Se puede hacer un redeploy?
- La hemos liado! Necesito un rollback!
7. El juego de las variables de grupo, proyecto y pipeline
8. Nuestra primera aplicación en flask
- Como se hace un build de una app en docker
- Deploy ficticio en docker in docker
- Redeploy de la aplicación
- Rollback de la aplicación
9. Ejemplo de aplicación de spring con tests
10. Conatiner Registry
- Creando nuestras propias imágenes base
- usando nuestras propias imágenes base
12. Gitlab Pages




