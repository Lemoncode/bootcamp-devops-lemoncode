# Día 2: Trabajando con imágenes

![Docker](imagenes/Trabajando%20con%20imagenes%20de%20Docker.jpeg)


En la primera clase vimos cómo instalar Docker, cómo funcionan los contenedores y cómo crear y ejecutar un contenedor a partir de una imagen. En esta clase vamos a ver cómo trabajar con imágenes, cómo buscarlas, descargarlas, crearlas y subirlas a Docker Hub.

## Comprobar las imagenes que ya tenemos en local

Pero antes de empezar vamos a recordar cómo podíamos ver las imágenes que tenemos en local:

```bash
docker images
```

o bien

```bash
docker image ls
```

Y recientemente ha salido una nueva opción, con la versión 4.34.2 en la que podemos ver incluso la arquitectura de la imagen:

![Software updates](imagenes/Software%20updates%20de%20Docker%204.34.2.png)

```bash
docker image list --tree
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

#Formateo de la salida usando Go
docker search --format "{{.Name}}: {{.StarCount}}" nginx
docker search --format "table {{.Name}}\t{{.Description}}\t{{.IsAutomated}}\t{{.IsOfficial}}" nginx

# El CLI no te devuelve los tags, pero puedes hacerlo así, instalando JQ (https://stedolan.github.io/jq/)

curl -s -S 'https://registry.hub.docker.com/v2/repositories/library/nginx/tags/' | jq '."results"[]["name"]' | sort

#Crear un contenedor a partir de una imagen de docker
docker run -d --rm -p 9090:80 nginx

#Crear múltiples contenedores de una imagen
docker run -d --rm -p 7070:80 nginx
docker run -d --rm -p 6060:80 nginx

#### Crear tu propia imagen

# Dockerfile en contenedores-ii/Dockerfile

cat Dockerfile

#Construccion de la imagen utilizando el Dockerfile
docker build . --tag simple-nginx:v1

#o bien
docker build . -t simple-nginx:v1

cd ..
docker build . -t simple-nginx:v1

#Le decimos dónde está el Dockerfile, pero sigue fallando
docker build . -f contenedores-ii/Dockerfile -t simple-nginx:v1

#Cambio el contexto
docker build contenedores-ii/ -t simple-nginx:v1

docker images
#Ahora verás que tienes la imagen alpine descargada, al utilizarla como base, y una nueva llamada simple-nginx que tiene el tag v1

#Se ven todos los cambios que se han hecho para construir en esta imagen, tanto los que vienen
#de la base como los hechos en el propio Docker file
docker history simple-nginx:v1

#Inspeccionando la imagen puedes saber cuántas capas tiene la misma
docker inspect simple-nginx:v1
#Cada instrucción en el Dockerfile genera una capa

#Dive: herramienta para explorar imágenes
https://github.com/wagoodman/dive

#Para instalar en Macq
brew install dive

#Para instalar en Windows (necesitas Go 1.10+)
go get github.com/wagoodman/dive

#¿Cómo se usa?
dive simple-nginx:v1

#Ahora crea un contenedor con tu nueva imagen
docker run -d --name my_nginx -p 8080:80 simple-nginx:v1

docker ps

#Etiquetar una imagen para subirla a Docker Hub
docker tag simple-nginx:v1 0gis0/simple-nginx:v1

#Comprobamos que la nueva etiqueta se ha generado correctamente
docker images

#Subirla a Docker Hub
docker push 0gis0/simple-nginx:v1

#Para comprobar que podemos utilizar nuestra imagen ya en Docker Hub, debemos eliminar la copia que tenemos en local:

#Borramos la imagen de local, utilizando el ID
docker rmi simple-nginx:v1
#No nos va a dejar porque tenemos un contenedor ejecutandose con dicha imagen
docker rm -f my_nginx
#Ahora debería de dejarnos
docker rmi simple-nginx #como tiene varias etiquetas tampoco le molará.
docker rmi simple-nginx:v1 0gis0/simple-nginx:v1

#Ahora intentamos crear un contenedor pero con la imagen que ahora está en Docker Hub
docker run -d --name my_nginx -p 8080:80 0gis0/simple-nginx:v1

#Si intentamos eliminar una imagen y hay algún contenedor que la está utilizando no será posible, dará error, incluso si este ya terminó de ejecutarse.
docker rmi simple-nginx:v1

#Eliminar una imagen
docker image rm 0gis0/simple-nginx:v1
docker rmi 0eb3967e4af2
docker image rm nginx 0gis0/simple-nginx:v1

#Eliminar SOLO las imágenes que no se están utilizando
docker image prune -a

#Listar los ids de las imágenes en local
docker images -q

#Eliminar todas las imágenes
docker rmi $(docker images -q) -f

#Automatizar una build a partir del código fuente de tu aplicación
#Accede a https://hub.docker.com con tu usuario y selecciona el repositorio simple-nginx.
#En el apartado BUILDS puedes configurar como fuente tanto GitHub como Bitbucket para la generación de la imagen.
