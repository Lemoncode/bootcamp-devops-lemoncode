# Día 2: Trabajando con imágenes

![Docker](imagenes/Trabajando%20con%20imagenes%20de%20Docker.jpeg)


En la primera clase vimos cómo instalar Docker, cómo funcionan los contenedores y cómo crear y ejecutar un contenedor a partir de una imagen. En esta clase vamos a ver cómo trabajar con imágenes, cómo buscarlas, descargarlas, crearlas y subirlas a Docker Hub.

## Crear un contenedor a partir de una imagen de docker

Como ya vimos en el primer día, para crear un contenedor a partir de una imagen de Docker, simplemente tenemos que ejecutar el siguiente comando:

```bash
docker run -d --rm -p 9090:80 nginx
```

Puedes crear tantos contenedores como quieras a partir de la misma imagen:

```bash
docker run -d --rm -p 7070:80 nginx
docker run -d --rm -p 6060:80 nginx
```

Lo bueno de ello es que una vez que tienes esta imagen en local la ejecución de un contenedor es muy rápida, ya que no tienes que descargar la imagen de nuevo.

## Comprobar las imagenes que ya tenemos en local

Pero antes de empezar vamos a recordar cómo podíamos ver las imágenes que tenemos en local:

```bash
docker images
```

o bien

```bash
docker image ls
```

También podemos Filtrar por nombre del repositorio

```bash
docker images nginx
```

O filtrar por nombre del repositorio y tag

```bash
docker images mcr.microsoft.com/mssql/server:2019-latest
```

También podemos filtrar el resultado usando --filter

```bash
docker images --filter="label=maintainer=NGINX Docker Maintainers <docker-maint@nginx.com>"
```

## Pulling o descargar una imagen

Para descargar una imagen no es necesario tener que ejecutar un contenedor, simplemente con el comando `pull` es suficiente.

```bash
docker pull mysql
```

Si no especificamos nada más se descargará la imagen con la etiqueta `latest`, pero si queremos una versión específica podemos hacerlo de la siguiente manera:

```bash
docker pull mysql:5.7
```
Si ahora haces un `docker images` verás que tienes la imagen de mysql con la versión 5.7.

Para asegurarte de que estás descargando la imagen correcta puedes hacerlo por su hash específico, que se llama digest:

```bash
docker images --digests
```

```bash
docker pull redis@sha256:800f2587bf3376cb01e6307afe599ddce9439deafbd4fb8562829da96085c9c5
```

## Descargar todas las versiones/tags de una imagen

Si por algún motivo necesitas descargar todas las versiones de una imagen puedes hacerlo de la siguiente manera:

```bash
docker pull -a wordpress
```

Si bien es cierto que antes funcionaba este comando sin problemas ahora mismo debido a este mensaje: `[DEPRECATION NOTICE] Docker Image Format v1 and Docker Image manifest version 2, schema 1 support is disabled by default and will be removed in an upcoming release. Suggest the author of docker.io/library/wordpress:3 to upgrade the image to the OCI Format or Docker Image manifest v2, schema 2. More information at https://docs.docker.com/go/deprecated-image-specs/` no se puede hacer. Este mensaje significa que la imagen que estás intentando descargar no es compatible con la versión actual de Docker.


## Algunas imágenes interesantes

Las de [LinuxServer](https://www.linuxserver.io/) son muy interesantes, ya que tienen imágenes de aplicaciones muy conocidas como Plex, Nextcloud, etc.

Un servidor de **Radarr** (gestor de películas):

```bash
docker run \
--name=radarr \
-e UMASK_SET=022 `# control permissions of files and directories created by Radarr` \
-e TZ=Europe/Madrid `# Specify a timezone to use EG Europe/London, this is required for Radarr` \
-p 7878:7878 `# The port for the Radarr webinterface` \
linuxserver/radarr:5.11.0
```

**Plex** (servidor de medios):

```bash
docker run \
--name plex \
-p 32400:32400 \
-d \
linuxserver/plex
```

**DuckDNS** (para tener un dominio gratuito) ⚠️ pendiente de probar

```bash
docker run -d \
--name=duckdns \
--net=host `#optional` \
-e PUID=1000 `#optional` \
-e PGID=1000 `#optional` \
-e TZ=Etc/UTC `#optional` \
-e SUBDOMAINS=subdomain1,subdomain2 \
-e TOKEN=token \
-e UPDATE_IP=ipv4 `#optional` \
-e LOG_FILE=false `#optional` \
-v /path/to/duckdns/config:/config `#optional` \
--restart unless-stopped \
lscr.io/linuxserver/duckdns:latest
```

**VS Code Server** (Visual Studio Code en un contenedor)

```bash
docker run -d \
--name=code-server \
-e PUID=1000 \
-e PGID=1000 \
-e TZ=Etc/UTC \
-e PASSWORD=lemoncode \
-p 8443:8443 \
lscr.io/linuxserver/code-server:latest
```

Blender (software de modelado 3D)

```bash
docker run -d \
--name=blender \
-e PUID=1000 \
-e PGID=1000 \
-e TZ=Etc/UTC \
-p 3000:3000 \
-p 3001:3001 \
lscr.io/linuxserver/blender:latest
```

Speedtest Tracker (para hacer tests de velocidad) > Pendiente de probar
https://docs.speedtest-tracker.dev/getting-started/installation/installation

```bash
docker run -d --name speedtest-tracker \
 -p 9090:80 \
-p 8443:443 \
-e PUID=1000 \
-e PGID=1000 \
-e APP_KEY=base64:nyXzCn22VeDmKSdUqul5IOFUFCFv3UoZ02FQm0y+8uk= \
-e DB_CONNECTION=sqlite \
lscr.io/linuxserver/speedtest-tracker:latest
```

Filezilla (cliente FTP)

```bash
docker run -d \
  --name=filezilla \
  --security-opt seccomp=unconfined `#optional` \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -p 3000:3000 \
  -p 3001:3001 \
  --restart unless-stopped \
  lscr.io/linuxserver/filezilla:latest
```

[Aquí](https://fleet.linuxserver.io/) puedes ver todas las que tienen.


## Otros registros diferentes a Docker Hub

Hasta ahora hemos estado trabajando con Docker Hub, pero hay otros registros de imágenes como Artifact Registry de Google, el cual ha sustituido a Google Container Registry, Azure Container Registry, Amazon Elastic Container Registry, etc. con los que también puedes trabajar. En general estos son los que se suelen usar en los entornos corporativos.


### Google Container Registry > Artifact Registry

Para que veas cómo funciona, vamos a descargar una imagen de Artifact Registry de Google.

```bash
docker run  -p 8080:8080 gcr.io/google-samples/hello-app:1.0
```

### Microsoft Artifact Registry

```bash
docker run mcr.microsoft.com/mcr/hello-world
```

## Buscar imágenes en Docker Hub

Ya vimos en el primer día cómo buscar imágenes en Docker Hub, pero vamos a recordarlo.

Podemos hacerlo a através del CLI de Docker:

```bash
docker search microsoft
docker search google
docker search aws
```


Que nos devuelva aquella con al menos 50 estrellas:

```bash
docker search --filter=stars=50 --no-trunc nginx
```

También puedes pedirle que devuelva solo la oficial:

```bash
docker search --filter is-official=true nginx
```
O incluso puedes formatear la salida de lo que te devuelve `docker search`:

```bash
docker search --format "{{.Name}}: {{.StarCount}}" nginx
docker search --format "table {{.Name}}\t{{.Description}}\t{{.IsAutomated}}\t{{.IsOfficial}}" nginx
```

## El CLI no te devuelve los tags, pero puedes hacerlo así, instalando JQ (https://stedolan.github.io/jq/)

Por otro lado, si quieres ver los tags de una imagen en Docker Hub puedes hacerlo de la siguiente manera:

```bash
curl -s -S 'https://registry.hub.docker.com/v2/repositories/library/nginx/tags/' | jq '."results"[]["name"]' | sort
```

## Crear tu propia imagen a partir de una imagen existente

Vamos a tomar por ejemplo la imagen llamada nginx y vamos a crear una imagen propia a partir de ella utilizando un contenedor el cual vamos a utilizar para modificar el contenido.

```bash
docker run -d --name nginx-container -p 8080:80 nginx
```

Ahora lo que vamos a hacer es utilizar el contenido del directorio llamado `web` para modificar lo que hay en el directorio `/usr/share/nginx/html` del contenedor.

```bash
docker cp 01-contenedores/contenedores-ii/web/. nginx-container:/usr/share/nginx/html
```

Ahora que ya hemos modificado la imagen vamos a crear una nueva imagen a partir de ella. Para ello vamos a hacer un `commit` de la imagen.

```bash
docker commit nginx-container whale-nginx:v1
```

Si ahora haces un `docker images` verás que tienes una nueva imagen llamada `whale-nginx` con la etiqueta `v1`.

```bash
docker images
```

Y ahora vamos a crear un nuevo contenedor a partir de esta imagen:

```bash
docker run -d --name whale-nginx -p 8081:80 whale-nginx:v1
```

## Inspeccionando una imagen

Para inspeccionar una imagen puedes hacerlo de la siguiente manera:

```bash
docker inspect whale-nginx:v1
```

El apartado llamado `Layers` te indica cuántas capas tiene la imagen. Esto es importante porque cada instrucción en el Dockerfile genera una capa, excepto las que contienen metadata.

## Dive: herramienta para explorar imágenes

Existe una herramienta llamada Dive que te permite explorar las capas de una imagen. Para instalarla simplemente tienes que hacer lo siguiente:

```bash
https://github.com/wagoodman/dive
```

En MacOs:

```bash
brew install dive
```

O en Windows:

```bash
go get github.com/wagoodman/dive
```

Ok ¿y cómo se usa? Pues simplemente tienes que ejecutar el siguiente comando:

```bash
dive nginx
```

A día de hoy esto mismo puedes hacer en Docker Desktop, simplemente seleccionando la imagen:

![Capas de una imagen en Docker Desktop](imagenes/Capas%20de%20una%20imagen.png)

## Eliminar una imagen

Si intentamos eliminar una imagen y hay algún contenedor que la está utilizando no será posible, dará error, incluso si este ya terminó de ejecutarse.

```bash
docker rmi whale-nginx:v1
```

Si quisiéramos eliminar SOLO las imágenes que no se están utilizando:

```bash
docker image prune -a
```