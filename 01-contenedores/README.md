# Módulo 2 - Contenedores Docker

## Agenda

### Día I: Introducción a Docker (27 de Septiembre de 2021)

#### Teoría
- Introducción a Docker y por qué Docker
- ¿Por dónde empiezo?
    * Docker Desktop    

#### Práctica

- Comandos básicos:
    * docker version y docker info
    * Ejecutar tu primer contenedor
    * Introducción a las imágenes
    * Docker Hub
    * Exponer puertos de un contenedor
    * ¿Dónde están los contenedores?
    * Personalizar el nombre de los contenedores
    * Ejecutar un contenedor y lanzar un terminal dentro de él
    * Conectarme a un contenedor
    * Ejecutar comandos dede mi local dentro del contenedor
    * Copiar archivos desde local a un contenedor y viceversa
    * Cómo parar/iniciar un contenedor ya creado    
    * Eliminar contenedores
    * Docker Desktop Dashboard para la gestión de contenedores
- Ejemplo práctico: SQL Server dockerizado
#### El resumen de hoy
#### Chuleta de comandos
#### Deberes

### Día II: Trabajando con imágenes (28 de Septiembre de 2021)

#### Teoría

- Introducción a las imágenes
- Los registros

#### Práctica

- Ver todas las imágenes en local hasta ahora
- Buscar entre las imágenes descargadas
- Descargar una imagen sin tener que ejecutar un contenedor
- Descargar una versión/tag específico de una imagen
- Descargar una imagen a través de su digest
- Descargar todas las versiones/tags de una imagen
- Pull desde un registro diferente a Docker Hub
- Buscar imágenes en Docker Hub con docker search
- Crear un contenedor a partir de una imagen de docker
- Crea tu propia imagen
  * El Dockerfile
  * Construir imagen a partir del Dockerfile
  * Histórico de una imagen
  * Inspeccionando una imagen
  * Dive: herramienta para explorar imágenes
  * Ejecutar un contenedor con tu nueva imagen
  * Subir tu imagen a Docker Hub
- Eliminar imágenes
#### El resumen de hoy
#### Chuleta de comandos
#### Deberes


### Día III: Contenerización de aplicaciones (4 de Octubre de 2021)

#### Teoría

- ¿Por qué queremos contenerizar nuestras aplicaciones?
- Proceso de contenerización
- El Dockerfile
- Capas
- Cómo generar imágenes
- Publicar imágenes
- Buenas prácticas

### Prática

- Visual Studio Code y Docker
- Dockerfiles multi-stages
- Ejemplo de contenerizaión de una aplicación en un entorno .NET
- Ejemplo de aplicación Java con IntelliJ
- Ejemplo de aplicación con un contenedor Windows

#### El resumen de hoy
#### Chulera de comandos
#### Deberes

### Día IV: Almacenamiento y monitorización (5 de Octubre de 2021)

#### Teoría del almacenamiento

- Introducción al almacenamiento
- Capas de lectura y del contenedor
- Datos persistentes
- Tipos de montaje

#### Práctica del almacenamiento

- Listar los volúmenes de un host
- Crear un nuevo volumen
- Asociar varios contenedores al mismo volumen
- Comprobar qué contenedores están asociados a un volumen
- Inspeccionar un volumen
- Añadir datos a un volumen
- Eliminar un contenedor con un volumen asociado
- Asociar un nuevo contenedor a un volumen existente
- Usar Visual Studio Code con Explore in Development Container
- Ejemplo de bind mount
- Usar el bind mount como read-only
- Backup de un volumen
- Eliminar un volumen
- Un volumen no puede eliminarse mientras esté atachado
- Eliminar todos los volúmenes que no estén siendo usados
- Tmpfs mount

#### Resumen de este apartado
#### Chuleta de comandos

#### Teoría de monitorización

- Introducción a la monitorización
- Tipos de logs
- Docker events
- Docker stats
- Docker logs

#### Práctica de monitorización

- Ver qué eventos genera Docker
- Métricas en Docker
- Saber cuánto espacio estamos ocupando en disco
- Prometheus
- Grafana
- Cómo ver los logs de un contenedor
- Fluentd
- Portainer.io

#### Resumen del apartado
#### Chuleta de comandos

### Día V: Networking (18 de Octubre de 2021)

#### Teoría

- Fundamentos de redes
- ¿Qué es un DNS?
- Network namespaces
- Docker y el networking
- CNI
- CNM

#### Práctica

- Listar redes disponibles en un host
- Los contenedores por defecto se meten en la red bridge
- Dos contenedores en la red por defecto
- Cómo crear una red
- Añadir un contenedor a una red específica
- Asociar un contenedor a dos redes
- Lo que habíamos visto hasta ahora: port mapping
- Exponer todos los puertos descritos como EXPOSE en la imagen
- Ejemplo de un contenedor en la red de tipo host
- Deshabilitar la red para un contenedor
- Eliminar una red
- Eliminar todas las redes que no se estén utilizando
- Crear una red de tipo overlay
- Apartado Networks en Visual Studio Code

#### Resumen del día
#### Chuleta de comandos
#### Ejercicios

### Día VI: Docker Compose y Docker Swarm (19 de Octubre de 2021)

#### Teoría de Docker Compose

- Introducción a los microservicios
- Introducción a Docker Compose

#### Práctica de Docker Compose

- Desplegar un Wordpress de forma manual
- El archivo docker-compose.yaml
- Ejecutar aplicación con Docker Compose
- Parar la aplicación
- Ejecutar la aplicación en segundo plano
- Eliminar la aplicación
- Desplegar una aplicación propia generando la imagen
- ver todas las aplicaciones que se están ejecutando a través de Docker Compose
- Ver todos los proyectos levantados con Docker Compose
- Asignar un nombre al proyecto
- Reiniciar los contenedores de la aplicación

#### Resumen de la parte de Docker Compose
#### Chuletas de Docker Compose

#### Teoría de Docker Swarm

- ¿Qué es Docker Swarm?
- ¿Cómo funciona?
- Alta disponibilidad
- Balanceo de Carga
* Modo Ingress
* Modo host

#### Práctica de Docker Swarm

- Como iniciar un clúster con Docker Swarm
- Docker Machine para crear VMs con Docker Engine
- Crear un clúster con Docker Machine
- Desplegar una aplicación en nuestro nuevo clúster
- Escalar la aplicación
- Constraints para desplegar los servicios solamente en los workers
- Visualizador de un Swarm
- Modo Ingress
- Modo Host
- Docker Stacks

#### Resumen de la parte de Docker Swarm
#### Chuleta de comandos
#### Ejercicios

### Laboratorio de Docker (25 de Octubre de 2021)
