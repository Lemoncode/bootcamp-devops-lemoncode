# GitLab BOOTCAMP

![](https://about.gitlab.com/images/press/logo/jpg/gitlab-logo-gray-rgb.jpg)

<p  align="center">

<img  src="https://avatars.githubusercontent.com/u/7702396?s=200&v=4">

</p>

  

> **El entorno está preparado para funcionar tanto en docker(Recomendado) en local o con una maquina virtual vagrant**

## Versiones de software
###  Entorno Docker (Recomendado)
- Docker Engine: >= 20
- [Docker Compose plugin](https://docs.docker.com/compose/install/)

### Entorno Vagrant
- Vagrant: >= 2.2.x
- VirtualBox >= 6.x

## Creación del entorno

1. Permitimos registry inseguro a docker

* En Linux En el fichero /etc/docker/daemon.json

```
{"insecure-registries" : ["gitlab.local:5001", "gitlab.local:8888"]}
```

* En windows lo hacemos via Docker Desktop

2. Acceso al directorio de gitlab damos permisos de ejecucion al script de preparacion del entorno de gitlab.
Con el script `gitlab_environment.sh`podemos ejecutar, parar y destruir los entornos de gitlab, ya sea con Docker o Vagrant.
```bash
user@localhost:~/bootcamp-devops-lemoncode$  cd  03-cd/02-gitlab
user@localhost:~/bootcamp-devops-lemoncode/03-cd/02-gitlab$ sudo  chmod  +x gitlab_environment.sh
```
2a. Preparando el entorno con docker (Linux y Windows WSL).

```
user@localhost:~/bootcamp-devops-lemoncode/03-cd/02-gitlab$ sudo ./gitlab_environment.sh  
1 - Docker environment  
2 - Vagrant environment  
### Choose the Gitlab environment ###  
1  
1 - Build and run gitlab  
2 - Stop gitlab  
3 - Start gitlab  
4 - Destroy gitlab  
### Choose your option and press enter ###  
1  
### Preparing gitlab environment ###  
  
[+] Running 10/10  
✔ Network bootcamp_network Created  0.0s  
✔ Network gitlab_default Created  0.1s  
✔ Volume "gitlab_gitlab-logs" Created  0.0s  
✔ Volume "gitlab_gitlab-data" Created  0.0s  
✔ Volume "gitlab_gitlab-runner-config" Created  0.0s  
✔ Volume "gitlab_portainer_data" Created  0.0s  
✔ Volume "gitlab_gitlab-config" Created  0.0s  
✔ Container gitlab Started  0.1s  
✔ Container portainer Started  0.1s  
✔ Container gitlab-runner Started
...

```

2b. Preparando el entorno con Vagrant y Virtualbox

```bash

user@localhost:~/bootcamp-devops-lemoncode/03-cd/02-gitlab$ sudo ./gitlab_environment.sh  
1 - Docker environment  
2 - Vagrant environment  
### Choose the Gitlab environment ###  
2
1 - Build and run gitlab vagrant machine  
2 - Suspend gitlab vagrant machine  
3 - Resume gitlab vagrant machine  
4 - Destroy gitlab vagrant machine  
1
### Preparing gitlab vagrant machine ###  
  
Bringing machine 'bootcampVM' up with 'virtualbox' provider...  
==> bootcampVM: Box 'ubuntu/jammy64' could not be found. Attempting to find and install...  
bootcampVM: Box Provider: virtualbox  
bootcampVM: Box Version: 20231027.0.0  
==> bootcampVM: Loading metadata for box 'ubuntu/jammy64'  
bootcampVM: URL: https://vagrantcloud.com/ubuntu/jammy64  
==> bootcampVM: Adding box 'ubuntu/jammy64' (v20231027.0.0) for provider: virtualbox
...
```

3. Añadimos entrada al fichero hosts la entrada -> <Direccion_ip_local> gitlab.local

* Linux en el fichero /etc/hosts

* Windows en el fichero c:\windows\system32\drivers\etc\hosts

## Un poco de arquitectura

  

- Gitlab![](https://docs.gitlab.com/ee/development/img/architecture_simplified_v14_9.png)

- Gitlab Runner(https://docs.gitlab.com/runner/#runner-execution-flow)

- Gitlab Runner Executors(https://docs.gitlab.com/runner/executors/)

- CI/CD Architecture ![](https://docs.gitlab.com/ee/development/cicd/img/ci_architecture.png)

## ¿Qué vamos a aprender?

1. Conceptos Gitlab
    
    - ¿Qué es Gitlab?
    
    - ¿Qué es un runner?
    
    - ¿Qué es un pipeline?

2. Gestión de Usuarios
    
    - Alta de usuarios
    
    - Impersonate
    
    - SSH Keys
    
    - Access Token

3. Gestión de proyectos(repositorios)

    - Miembros del proyecto
    
    - Deploy Tokens
    
    - Deploy Keys
    
    - Protected Branches
    
    - Protected TAGS

4. Entendiendo los pipelines

    - Conceptos de Pipeline

        - ¿Qué es un pipeline?

        - ¿Como se define?
    
        - ¿Cuando se ejecuta?
    
        - ¿Qué es un stage?
    
        - ¿Qué es un Job?

- Herramientas para crear pipelines

    - Web IDE

    - PipeLine Editor

- Estructura básica

    - image

    - job

    - stage

    - script

    - before_script

- Variables de grupo, proyecto y pipeline

    - Variables predefinidas

    - Usando variables

    - Orden de precedencia

    - Casos de uso

- Control sobre los pipelines

    - Condicionales when y only

    - Condicionales avanzados con rules

    - Control de errores

- Artifacts

    - ¿Qué es un artifact?

    - ¿Para que lo usamos?

    - Casos de uso

- Environments

    - ¿Qué es un environment?

    - ¿Para que lo usamos?

    - Redeploy

    - Rollback

- Workflows

5. Creacion de pipelines de build,test y deploy

6. Uso de container registry

    - ¿Qué es un container registry?
    
    - Repositando nuestra imágenes

8. Pipelines de creación de imagenes Base

9. Usar nuestras Imágenes

10. Gitlab Pages

11. Bonus

    - Releases
    
    - Optimizando pipelines con Templates
    
    - Triggers

## Cheatsheet

### [Variables Predefinidas](http://gitlab.local:8888/help/ci/variables/predefined_variables.md)

### [Referencia configuración de pipeline](http://gitlab.local:8888/help/ci/yaml/index)

## Información usada en la Clase

### Gestion de Usuarios

- User: **root**, Pass: **Gitl@bPass** , Access Level: **Admin** (Usuario ya creado)

- User: **developer1**, Pass: **dev€loper1** , Access Level: **Regular**

- User: **developer2**, Pass: **dev€loper2** , Access Level: **Regular**

### [Roles]( http://gitlab.local:8888/help/user/permissions)

- Guest

- Reporter

- Developer

- Maintainer

- Owner

### [Visibilidad de grupos y proyectos](http://gitlab.local:8888/help/public_access/public_access.md)

-  **Private**: El grupo y sus proyectos sólo pueden ser vistos por los miembros.

-  **Internal**: El grupo y los proyectos internos pueden ser vistos por cualquier usuario conectado, excepto los usuarios externos.

-  **Public**: El grupo y los proyectos públicos pueden verse sin necesidad de autenticación.
