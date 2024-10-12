# Día 3: contenerización de aplicaciones

![Docker](./imagenes/Creando%20imagenes%20de%20Docker.jpeg)

## Aplicación de ejemplo

Para contenerizar una aplicación lo primero que necesitamos es un aplicativo que queramos contenerizar. En este caso, vamos a contenerizar una aplicación en Node.js, que está dentro del directorio `hello-world`. Y antes de contenerizarla es aconsejable ejecutarla en local para comprobar que funciona correctamente.


```bash
cd 01-contenedores/contenedores-iii/hello-world
npm install
npm run test
node server.js
npm run start-dev
``` 

## El archivo Dockerfile

Para poder contenerizar cualquier aplicación necesitamos un archivo llamado `Dockerfile`. Este archivo contiene las instrucciones necesarias para construir una imagen de Docker. Para conseguir este archivo tenemos varias maneras:

1. De forma manual: En este caso necesitamos conocer los comandos necesarios para construir una imagen de Docker. Puedes encontrar todos los que existen en la [documentación oficial](https://docs.docker.com/engine/reference/builder/). Para este caso, vamos a utilizar un archivo `Dockerfile` que ya está creado en el directorio `hello-world` llamado `Dockerfile`.


## Diferencia entre CMD y ENTRYPOINT
Un Dockerfile nos permite definir un comando a ejecutar por defecto, para cuando se inicien los contenedores a partir de nuestra imagen. Para ello tenemos dos comandos a nuestra disposición:
- `CMD` (comando): Docker ejecutará el comando que indiques usando el ENTRYPOINT por defecto, que es /bin/sh -c
- `ENTRYPOINT` (punto de entrada): Docker usará el ejecutable que le indiques, y la instrucción CMD te permitirá definir un parámetro por defecto.

## Diferencia entre ADD y COPY
Ambas te permiten copiar archivos de local dentro de una imagen de Docker. Sin embargo:

- `COPY` coge una fuente y un destino dentro de tu máquina local.
- `ADD` te permite hacer lo mismo que COPY, pero además puedes especificar una URL como origen o incluso extraer un archivo .tar y descomprimirlo directamente en destino.

## El archivo .dockerignore

El archivo `.dockerignore` es un archivo que se utiliza para indicar a Docker qué archivos y carpetas no debe incluir en la imagen. Es muy útil para evitar incluir archivos innecesarios en la imagen, como por ejemplo archivos de logs, archivos temporales, etc.

## Generar la imagen en base al Dockerfile

Una vez que tenemos el archivo `Dockerfile` y el archivo `.dockerignore` podemos generar la imagen de Docker. Para ello, necesitamos ejecutar el siguiente comando:

```bash
docker build -t hello-world:prod .
```

## Ejecutar un nuevo contenedor usando tu nueva imagen:

```bash
docker run -p 4000:3000 hello-world:prod
```

## Imágenes multi-stage

Cuando creamos im´genes de Docker, a veces necesitamos instalar herramientas adicionales para construir nuestra aplicación, como por ejemplo compiladores, linters, herramientas de testing, etc. Sin embargo, estas herramientas no son necesarias en la imagen final, ya que solo necesitamos el binario de nuestra aplicación. Si no lo tenemos en cuenta, nuestra imagen final será más grande de lo necesario.

```bash
docker images
```

Podemos ver el historico generado para la imagen para ver cuánto ocupa cada capa.

```bash
docker history helloworld #Los que tienen valor 0B son metadatos
```

Para que veas la vamos instalar todo lo que nuestra aplicación potencialmente puede instalar, para ello modifica el Dockerfile para ejecutar el test con eslint:

```Dockerfile
FROM node:14-alpine

LABEL maintainer="Gisela Torres <gisela.torres@returngis.net>"

# ENV NODE_ENV=production

WORKDIR /usr/src/app

COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]

# RUN npm install --production --silent && mv node_modules ../
RUN npm install

COPY . .
# #Ejecuta los tests de eslint
RUN npm test

EXPOSE 3000

RUN chown -R node /usr/src/app

USER node

CMD ["npm", "start"]
```

Ahora, si volvemos a generar la imagen, después de que arregles los errores que reporta eslint, comprobarás que ha engordado.

```bash
docker build --tag=helloworld . -f Dockerfile.dev
docker images
```

## Multi-stage Builds 

Con multi-stage lo que se hace es utilizar múltiples `FROM` dentro del mismo Dockerfile.
Cada `FROM` utiliza una imagen base diferente y cada una inicia un nuevo stage.
El último `FROM` produce la imagen final, el resto solo serán intermediarios.
Puedes copiar archivos de un stage a otro, dejando atrás todo lo que no quieres para la imagen final.
La idea es simple: crea imagenes adicionales con las herramientas que necesitas (compiladores, linters, herramientas de testing, etc.) pero que no son necesarias para producción
El objetivo final es tener una imagen productiva lo más slim posible y segura. Mismo ejemplo con multi-stages:

```bash
DOCKER_BUILDKIT=0 docker  build -t helloworld:multi-stage . -f Dockerfile.multistages
```

Si revisamos las imágenes finales, helloworld:multi-stage y helloworld:prod deberían de tener el mismo peso

```bash
docker images
```

Existen lo que se llaman las imágenes intermedias, que son las que se generan en cada uno de los stages. Para eliminarlas, podemos ejecutar el siguiente comando:

```bash
docker image prune
```

2. Usando el comando `docker init`
3. Usando la extensión de Docker de Visual Studio Code: Basta con  ejecutar Cmd + P > Add Docker Files to Workspace y seleccionar Node.js. Te pedirá que le selecciones el package.json y el puerto que utiliza tu app.
Le diremos que no queremos el archivo de Docker compose, lo dejaremos para más adelante 😃.
4. Usando IA, como por ejemplo con Microsoft Edge.
5. Usando GitHub Copilot