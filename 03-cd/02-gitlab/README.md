# GitLab BOOTCAMP

![](https://about.gitlab.com/images/press/logo/jpg/gitlab-logo-gray-rgb.jpg)

<p  align="center">

<img  src="https://avatars.githubusercontent.com/u/7702396?s=200&v=4">

</p>

  

> **El entorno está preparado para funcionar tanto en docker(Recomendado) en local o con una maquina virtual vagrant**

> **Importante** - Esta configuración está destinada únicamente para entornos de desarrollo. No debe ser utilizada como referencia en un entorno productivo.

## Versiones de software
###  Entorno Docker (Recomendado)
- Docker Engine: >= 20

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
>**Nota Importante**: Si usamos vagrant la ip sera la de la maquina virtual  -> 192.168.56.150

* Linux en el fichero /etc/hosts

* Windows en el fichero c:\windows\system32\drivers\etc\hosts

## ¿Qué vamos a aprender?

1. Conceptos Gitlab
    
    - ¿Qué es Gitlab?

      GitLab es una plataforma completa de DevOps que cubre todo el ciclo de vida del desarrollo de software, desde la planificación hasta la implementación. Ofrece un lugar centralizado donde los equipos pueden gestionar el código fuente, realizar pruebas, automatizar el despliegue y mucho más.
      - [Gitlab Architecture](https://docs.gitlab.com/ee/development/architecture.html)

    - ¿Qué es un runner?

      Un GitLab Runner es una aplicación que ejecuta los trabajos de un pipeline dentro de un proyecto de GitLab. En otras palabras, los runners son los encargados de ejecutar el código o las tareas definidas en el pipeline de un proyecto. GitLab Runner puede ejecutarse en diversos entornos, como servidores físicos, virtuales, en contenedores Docker, entre otros.
       - [Gitlab Runner Executors](https://docs.gitlab.com/runner/executors/)
       - [Gitlab Runner Execution Flow](https://docs.gitlab.com/runner/#runner-execution-flow)

    - ¿Qué es un pipeline?

      Un pipeline en GitLab (y en el contexto de la integración continua y entrega continua, CI/CD) es un conjunto de tareas o trabajos automatizados que se ejecutan de manera secuencial o paralela para llevar a cabo una serie de procesos durante el desarrollo de un software.
      
2. Gestión de Usuarios
    
    - Alta de usuarios
    - Impersonate
    - SSH Keys
    - Access Token

3. Gestión de proyectos(repositorios) y grupos:

    - Miembros - [Roles and permissions](https://docs.gitlab.com/ee/user/permissions.html)
    - [Project Access Tokens](https://docs.gitlab.com/ee/user/project/settings/project_access_tokens.html)
    - [Group Access Tokens](https://docs.gitlab.com/ee/user/group/settings/group_access_tokens.html)
    - [Deploy Tokens](https://docs.gitlab.com/ee/user/project/deploy_tokens/)
    - [Deploy Keys](https://docs.gitlab.com/ee/user/project/deploy_keys/)
    - [Protected Branches](https://docs.gitlab.com/ee/user/project/repository/branches/protected.html)
    - [Protected Tags](https://docs.gitlab.com/ee/user/project/protected_tags.html)

4. Entendiendo los pipelines

    - Conceptos de Pipeline
        - ¿Como se define?

          Todas estas tareas estan definidas en un archivo de configuración llamado .gitlab-ci.yml.
          - [Referencia configuración de pipeline](https://docs.gitlab.com/ee/ci/yaml/)
        
        - ¿Cuando se ejecuta? https://docs.gitlab.com/ee/ci/pipelines/
       
          - Branch pipelines
          - Merge request pipeline
          - Tag pipeline
          - Scheduled pipeline
          - Parent-child pipeline
          - Multi-project pipeline
        
        - ¿Qué es un job?

          Los jobs son las tareas concretas que se ejecutan dentro de cada stage.
        
        - ¿Qué es un stage?
        
          Es un nivel o fase dentro del pipeline que agrupa jobs relacionados entre sí y permite que estos se ejecuten en un orden específico.

- Editores
    - PipeLine Editor

      El Pipeline Editor de GitLab es una herramienta visual basada en la web que facilita la creación y gestión de pipelines de integración y entrega continua (CI/CD). Permite a los usuarios diseñar y configurar pipelines de manera intuitiva, sin tener que escribir manualmente los archivos de configuración en YAML. Con este editor, es posible definir las etapas, trabajos y otros aspectos de los pipelines de forma visual, validando la configuración en tiempo real para evitar errores.
    - Web IDE

      El Web IDE de GitLab es una herramienta de desarrollo totalmente basada en la web que permite a los usuarios escribir, modificar y gestionar su código directamente en GitLab, sin la necesidad de contar con un editor de código o IDE instalado en su equipo.

[Referencia configuración de pipeline](http://gitlab.local:8888/help/ci/yaml/index)
- Estructura básica de un pipeline
    - default
    - image
    - stage
    - script
    - before_script
    - after_script
    
- Variables de grupo, proyecto y pipeline
    - [Variables Predefinidas](https://docs.gitlab.com/ee/ci/variables/predefined_variables.html)
    - Usando variables
    - Orden de precedencia
    - Casos de uso

- Control sobre los pipelines
    - Workflows
    - Rules
    - Allow failure
    - Needs

- Artifacts

- Cache

- Environments
    - ¿Qué es un environment?
    - ¿Para que lo usamos?
    - Redeploy
    - Rollback

- Services

5. Uso de container registry y dependency proxy

    - ¿Qué es el container registry?, ¿y cómo se usa?
    - ¿Qué es el dependency proxy?, ¿y cómo se usa?

6. Creacion de pipelines de build,test, deploy y release
    - App python con flask
    - App springboot

7. Downstream pipelines
    - Multi-project pipelines
    - Parent-child pipelines

8. Gitlab Pages

9. Optimizando pipelines con Templates
    - Anchors
    - Extends
    - Reference Tags
    - includes

## Información usada en la Clase

- User: **root**, Pass: **Gitl@bPass** , Access Level: **Admin** (Usuario ya creado)

- User: **developer1**, Pass: **dev€loper1** , Access Level: **Regular**

- User: **developer2**, Pass: **dev€loper2** , Access Level: **Regular**
