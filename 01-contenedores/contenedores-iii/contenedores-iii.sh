# Parte 3: contenerización de aplicaciones #

#Mi primera applicación a contenerizar > Node.js
#Para esta demo usaremos VS Code.
https://code.visualstudio.com/docs/containers/overview
cd 01-contenedores/contenedores-iii/hello-world

#Ejecutar la app sin contenerizar
npm install
npm run test
node server.js
npm run start-dev

#Para crear el archivo Dockerfile y .dockerignore que vimos en la parte teórica, puedes hacerlo con la extensión de Docker de manera sencilla.
#Basta con  ejecutar Cmd + P > Add Docker Files to Workspace y seleccionar Node.js. Te pedirá que le selecciones el package.json y el puerto que utiliza tu app.
#Le diremos que no queremos el archivo de Docker compose, lo dejaremos para más adelante :-)

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

#Comprobamos las imágenes que ahora tenemos disponibles, así como el peso de hello-world
docker images

#Ver el historico generado para la imagen
docker history hello-world #Los que tienen valor 0B son metadatos

#Ejecutar un nuevo contenedor usando tu nueva imagen:
docker run -p 4000:3000 hello-world

#Modifica el Dockerfile para ejecutar el test con eslint:
# FROM node:12.18-alpine
# LABEL maintainer="Gisela Torres"
# # ENV NODE_ENV production
# WORKDIR /usr/src/app
# COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
# RUN npm install
# COPY . .
# RUN npm run test
# EXPOSE 3000
# CMD ["npm", "start"]

#Si vuelves a generar tu imagen, después de que arregles los errores que reporta eslint, comprobarás que ha engordado
docker images

### Multi-stage Builds ###
#Con multi-stage lo que se hace es utilizar múltiples FROM dentro del mismo Dockerfile.
#Cada FROM utiliza una imagen base diferente y cada una inicia un nuevo stage.
#El último FROM produce la imagen final, el resto solo serán intermediarios.
#Puedes copiar archivos de un stage a otro, dejando atrás todo lo que no quieres para la imagen final.
#La idea es simple: crea imagenes adicionales con las herramientas que necesitas (compiladores, linters, herramientas de testing, etc.) pero que no son necesarias para producción
#El objetivo final es tener una imagen productiva lo más slim posible y segura.
#Mismo ejemplo con multi-stages
docker build hello-world -t multi-stage -f Dockerfile.multistages
docker run -p 5000:3000 multi-stage

docker images

#Si comparas con la versión de la misma aplicación sin multi-stages, la diferencia es notable
docker build hello-world -t no-multi-stage -f Dockerfile.no.multistages --no-cache


#### Ejemplo de contenerización de una aplicación en un entorno .NET #####
#Visual Studio 2019
#1. Creación de un nuevo proyecto del tipo ASP.NET Core Web Application 
#2. Dejar seleccionado el tipo MVC (Dejar el check de Enable Docker Support deshabilitado)
#3. Create
#4. Botón derecho sobre el proyecto > Add > Docker Support > Target OS > Linux
# Generará un Dockerfile con Multi-stage 


### Ejemplo de aplicación en Java - IntelliJ IDEA/Eclipse ####
https://www.jetbrains.com/help/idea/running-a-java-app-in-a-container.html

# FROM openjdk:14
# COPY ./out/production/HelloDocker/ /tmp
# WORKDIR /tmp
# ENTRYPOINT ["java","HelloWorld"]

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
