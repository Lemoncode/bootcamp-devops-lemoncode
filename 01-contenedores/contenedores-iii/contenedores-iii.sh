# Parte 3: contenerización de aplicaciones #

#Mi primera applicación a contenerizar > Node.js
cd 01-contenedores/contenedores-iii/hello-world

#Ejecutar la app sin contenerizar
npm install
node server.js

#Revisar el archivo Dockerfile
cat Dockerfile

#Diferencia entre CMD y ENTRYPOINT
#Un Dockerfile nos permite definir un comando a ejecutar por defecto, para cuando se inicien los contenedores a partir de nuestra imagen. Para ello tenemos dos comandos a nuestra disposición:
# CMD (comando): Docker ejecutará el comando que indiques usando el ENTRYPOINT por defecto, que es /bin/sh -c
# ENTRYPOINT (punto de entrada): Docker usará el ejecutable que le indiques, y la instrucción CMD te permitirá definir un parámetro por defecto.

#Diferencia entre ADD y COPY
#Ambas te permiten copiar archivos de local dentro de una imagen de Docker.
#COPY coge una fuente y un destino dentro de tu máquina local.
#ADD te permite hacer lo mismo que COPY, pero además puedes especificar una URL como origen o incluso extraer un archivo .tar y descomprimirlo directamente en destino.


#Revisar el archivo .dockerignore
cat .dockerignore

#Generar la imagen en base al Dockerfile
docker build --tag=hello-world . 

#Ver el historico generado para la imagen
docker history hello-world #Los que tienen valor 0B son metadatos

#Ejecutar un nuevo contenedor usando tu nueva imagen:
docker run -p 4000:3000 hello-world

#Añadir una nueva etiqueta a tu nueva imagen
docker image tag hello-world 0gis0/hello-world:latest
docker images #El image ID es el mismo para ambas etiquetas porque apuntan a la misma imagen

#Publicar tu nueva imagen en Docker Hub
docker push 0gis0/hello-world:latest

#Si accedes a tu cuenta en Docker Hub verás tu nueva imagen, la cual acaba de ser publicada
https://hub.docker.com/

#Elimina la imagen de local
docker rm 5bfeba90ec4d  --force
docker rmi -f hello-world 0gis0/hello-world

#Ejecutar un nuevo contenedor usando mi nueva imagen en Docker Hub
docker run -p 4000:3000 0gis0/hello-world

### Multi-stage Builds ###
#Ejemplo sin multi-stage

#Ejemplo con multi-stage
#Con multi-stage lo que se hace es utilizar múltiples FROM dentro del mismo Dockerfile.
#Cada FROM utiliza una imagen base diferente y cada una inicia un nuevo stage.
#El último FROM produce la imagen final, el resto solo serán intermediarios.
#Puedes copiar archivos de un stage a otro, dejando atrás todo lo que no quieres para la imagen final.
#La idea es simple: crea imagenes adicionales con las herramientas que necesitas (compiladores, linters, herramientas de testing, etc.) pero que no son necesarias para producción
#El objetivo final es tener una imagen productiva lo más slim posible y segura.
git clone https://github.com/sdelements/lets-chat.git
docker build lets-chat -t multi-stage -f Dockerfile.multistages
# First image FROM alpine:3.5 AS bas – is a base Node image with: node, npm, tini (init app) and package.json
# Second image FROM base AS dependencies – contains all node modules from dependencies and devDependencies with additional copy of dependencies required for final image only
# Third image FROM dependencies AS test – runs linters, setup and tests (with mocha); if this run command fail not final image is produced
# The final image FROM base AS release – is a base Node image with application code and all node modules from dependencies

### Squash de una imagen ###


#### Ejemplo de contenerización de una aplicación en .NET #####
#Visual Studio 2019
#1. Creación de un nuevo proyecto del tipo ASP.NET Core Web Application 
#2. Dejar seleccionado el tipo MVC (Dejar el check de Enable Docker Support deshabilitado)
#3. Create
#4. Botón derecho sobre el proyecto > Add > Docker Support > Target OS > Linux
# Generará un Dockerfile con Multi-stage 



#Visual Studio Code
https://code.visualstudio.com/docs/containers/overview

#Demos con la extensión de Docker para Visual Studio Code
# Ejecutar un contenedor desde el explorador de imágenes


### Ejemplo de aplicación en Java - IntelliJ IDEA/Eclipse ####
https://www.jetbrains.com/help/idea/running-a-java-app-in-a-container.html


#Ejemplo de aplicación con un contenedor Windows
#Windows Base OS images: https://hub.docker.com/_/microsoft-windows-base-os-images
docker pull mcr.microsoft.com/windows/nanoserver:1903
docker images

docker run -it mcr.microsoft.com/windows/nanoserver:1903 cmd.exe
echo "Hello World!" > Hello.txt
exit

docker ps -a

#Crea una nueva imagen que incluya los cambios del primer contenedor que has ejecutado
#https://docs.docker.com/engine/reference/commandline/commit/
docker commit 7e5e29758e43 helloworld

#Cuando se complete tendrás una nueva imagen con el archivo Hello.txt
docker images

#Ahora ejecuta un nuevo contenedor con la imagen que acabas de crear
docker run --rm helloworld cmd.exe /s /c type Hello.txt

##### Buenas prácticas en la construcción de imágenes #########
# - Una aplicación por contenedor (que el contenedor tenga el mismo ciclo de vida que una aplicación. Además, facilita la monitorización).
# - Utiliza .dockerignore para omitir aquellos archivos/carpetas que no son necesarias para la construcción de la imagen.
# - Durante la generación de la imagen, siempre que se pueda, intenta colocar las instrucciones que tienden a cambiar en la parte final del fichero, para que Docker reutilice la caché en para las capas anteriores.
# - Agrupa instrucciones en una misma capa (el ejemplo claro de esto es cuando instalamos dependencias con apt o yum > instaladores de paquetes de Linux)
#   En vez de esto:

    # FROM debian:9
    # RUN apt-get update
    # RUN apt-get install -y nginx

#   Haz esto:

    # FROM debian:9
    # RUN apt-get update && \
    #     apt-get install -y nginx

# - Elimina herramientas innecesarias de la imagen: wget, netcat, etc. para evitar que los atacantes puedan usarlas si se diera el caso.
# - Utilizar imágenes base reducidas


#Deberes: 
# 1.
# 2.
# 3.