# Módulo 2 - Contenedores Docker

## Agenda

### Día I: Introducción a Docker (6 de Octubre)

- ¿Por dónde empiezo?
    * Docker Desktop
    * Docker en Linux
    * Docker CLI client: La línea de comandos interactiva
- Comandos básicos:
    * Ejecutar tu primer contenedor
    * Introducción a las imágenes
    * Docker Hub
    * Exponer puertos de un contenedor
    * ¿Dónde están los contenedores creados hasta ahora?
    * Personalizar el nombre de los contenedores
    * Ejecutar un contenedor y lanzar un shell interactivo en él
    * Ejecutar comandos desde mi local dentro del contenedor
    * Conectarme a un contenedor 
    * Copiar archivos desde local a un contenedor y viceversa
    * Cómo parar/iniciar un contenedor ya creado    
    * Eliminar contenedores
    * Docker Desktop Dashboard para la gestión de contenedores

- Ejemplo práctico: SQL Server dockerizado
- Deberes

### Día II: Trabajando con imágenes (13 de Octubre)

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
- Deberes


### Día III: Contenerización de aplicaciones (19 de Octubre)

- Mi primera aplicación a contenerizar > Node.js y Visual Studio Code
  * El Dockerfile
  * Ejecutar eslint como parte de la build  
- Multistage build
- Ejemplo de contenerización de una aplicación en un entorno .NET
- Ejemplo de aplicación Java con IntelliJ
- Ejemplo de aplicación web en PHP con Eclipse
- Ejemplo con contenedores Windows

### Día IV: Networking (20 de Octubre)

- Port Mapping
- Exponer todos los puertos descritos como EXPOSE
- docker0
- Listar las redes disponibles en un host
- Los contenedores por defecto se meten en la red bridge/NAT
- Inspeccionar una red
- Crear una nueva red
- Crear un contenedor asociado a una red específica
- Descubrimiento de servicios y comunicación entre contenedores de la misma red
- Un contenedor con dos endpoints
- Deshabilitar la red para un contenedor
- Crear una red de tipo overlay

### Día V: Almacenamiento y monitorización (26 de Octubre)
- Almacenamiento
  * Ver todos los volúmenes en el host
  * Crear un nuevo volumen
  * Inspeccionar un volumen
  * Añadir datos dentro de un volumen
  * Eliminar un contenedor con un volumen montado
  * Asociar un nuevo contendor a un volumen existente
  * Backup de un volumen
  * Eliminar un volumen
  * Un volumen no puede eliminarse mientras esté montado
  * Eliminar todos los volúmenes sin usar
  * Ejemplo de bind mount
  * Usar bind mount en modo lectura
  * Tmpfs mount
- Monitorización
  * Cómo ver los logs de un contenedor
  * Ejemplo de los drivers de logging con Fluentd
  * Métricas
  * Ejemplo con Prometheus