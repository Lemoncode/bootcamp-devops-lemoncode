# Parte 3: contenerización de aplicaciones #

#Mi primera applicación a contenerizar > Node.js
#Para esta demo usaremos VS Code.
https://code.visualstudio.com/docs/containers/overview
cd 01-contenedores/contenedores-iii/hello-world

#Ejecutar la app sin contenerizar
#1. Instalar las dependencias de la aplicación 
npm install
#2. Ejecutar ESLint
npm run test
#3. Ejecutar la app
node server.js
#4. Ejecutar la app usando Nodemon
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
docker build -t hello-world:prod .

#Ejecutar un nuevo contenedor usando tu nueva imagen:
docker run -p 4000:3000 hello-world:prod

# Hacer lo mismo con la extensión de Visual Studio Code
# 1. Generar la imagen
# 2. Ejecutar un contenedor en base a la imagen
# 3. Abrir el navegador usando la extensión
# 4. Engancharse al terminal del contenedor

# El por qué del multi-stage

#Comprobamos las imágenes que ahora tenemos disponibles, así como el peso de helloworld
docker images

#Ver el historico generado para la imagen
docker history helloworld #Los que tienen valor 0B son metadatos


#Modifica el Dockerfile para ejecutar el test con eslint:
# FROM node:14-alpine

# LABEL maintainer="Gisela Torres <gisela.torres@returngis.net>"

# # ENV NODE_ENV=production

# WORKDIR /usr/src/app

# COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]

# # RUN npm install --production --silent && mv node_modules ../
# RUN npm install

# COPY . .
# #Ejecuta los tests de eslint
# RUN npm test

# EXPOSE 3000

# RUN chown -R node /usr/src/app

# USER node

# CMD ["npm", "start"]
docker build --tag=helloworld . -f Dockerfile.dev


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
DOCKER_BUILDKIT=0 docker  build -t helloworld:multi-stage . -f Dockerfile.multistages

# si revisamos las imágenes finales, helloworld:multi-stage y helloworld:prod deberían de tener el mismo peso
docker images

#Limpiar las imagenes dangling (intermedias de los multi-stages)
docker image prune

#### Ejemplo de contenerización de una aplicación en un entorno .NET #####
#Visual Studio 2019
#1. Creación de un nuevo proyecto del tipo ASP.NET Core Web Application 
#2. Dejar seleccionado el tipo MVC (Dejar el check de Enable Docker Support deshabilitado)
#3. Create
#4. Botón derecho sobre el proyecto > Add > Docker Support > Target OS > Linux
# Generará un Dockerfile con Multi-stage 


### Ejemplo de aplicación en Java - IntelliJ IDEA/Eclipse ####
https://www.jetbrains.com/help/idea/running-a-java-app-in-a-container.html

# FROM openjdk:16
# WORKDIR /app
# COPY ./out/production/HelloDocker/ .
# ENTRYPOINT ["java","com.example.lemoncode.HelloWorld"]


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
