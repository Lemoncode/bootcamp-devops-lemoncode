# Día 3: contenerización de aplicaciones

![Docker](./imagenes/Creando%20imagenes%20de%20Docker.jpeg)

## Aplicación de ejemplo

Para contenerizar una aplicación lo primero que necesitamos es un aplicativo que queramos contenerizar. En este caso, vamos a contenerizar una aplicación en Node.js, que está dentro del directorio `hello-world`. Y antes de contenerizarla es aconsejable ejecutarla en local para comprobar que funciona correctamente.


```bash
cd 01-contenedores/contenedores-iii/doom-web
npm install
npm run test
node server.js
npm run start-dev
```

> [!NOTE]
> Ejemplo sacado de https://codepen.io/cobra_winfrey/pen/oNOMRav

## El archivo Dockerfile

Para poder contenerizar cualquier aplicación necesitamos un archivo llamado `Dockerfile`. Este archivo contiene las instrucciones necesarias para construir una imagen de Docker. Para conseguir este archivo tenemos varias maneras:

### 1. De forma manual

En este caso necesitamos conocer los comandos necesarios para construir una imagen de Docker. Puedes encontrar todos los que existen en la [documentación oficial](https://docs.docker.com/engine/reference/builder/). Para este caso, vamos a utilizar un archivo `Dockerfile` que ya está creado en el directorio `hello-world` llamado `Dockerfile`.


## El archivo .dockerignore

El archivo `.dockerignore` es un archivo que se utiliza para indicar a Docker qué archivos y carpetas no debe incluir en la imagen. Es muy útil para evitar incluir archivos innecesarios en la imagen, como por ejemplo archivos de logs, archivos temporales, etc.

## Generar la imagen en base al Dockerfile

Una vez que tenemos el archivo `Dockerfile` y el archivo `.dockerignore` podemos generar la imagen de Docker. Para ello, necesitamos ejecutar el siguiente comando:

```bash
docker build -t doom-web:prod .
```

Si ahora comprobamos las imágenes que tenemos en nuestro sistema, deberíamos ver la imagen que acabamos de crear:

```bash
docker images
```

Si queremos ver el historial de la imagen que acabamos de crear, podemos ejecutar el siguiente comando:

```bash
docker history doom-web:v1
```

## Ejecutar un nuevo contenedor usando tu nueva imagen:

```bash
docker run -p 8080:3000 doom-web:v1
```

## Imágenes multi-stage

Cuando creamos imágenes de Docker, a veces necesitamos instalar herramientas adicionales para construir nuestra aplicación, como por ejemplo compiladores, linters, herramientas de testing, etc. Sin embargo, estas herramientas no son necesarias en la imagen final, ya que solo necesitamos el binario de nuestra aplicación. Si no lo tenemos en cuenta, nuestra imagen final será más grande de lo necesario.


Para que veas la vamos instalar todo lo que nuestra aplicación potencialmente puede instalar, para ello modifica el Dockerfile para ejecutar el test con eslint:

```Dockerfile
FROM node:20-alpine

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
docker build --tag=doom-web:v2 . -f Dockerfile.dev
docker images
```

En este caso la imagen solo pesa 1 mega más que la anterior, pero si tu aplicación es más grande, la diferencia puede ser mucho mayor.

## Multi-stage Builds 

Con multi-stage lo que se hace es utilizar múltiples `FROM` dentro del mismo Dockerfile.
Cada `FROM` utiliza una imagen base diferente y cada una inicia un nuevo stage.
El último `FROM` produce la imagen final, el resto solo serán intermediarios.
Puedes copiar archivos de un stage a otro, dejando atrás todo lo que no quieres para la imagen final.
La idea es simple: crea imagenes adicionales con las herramientas que necesitas (compiladores, linters, herramientas de testing, etc.) pero que no son necesarias para producción
El objetivo final es tener una imagen productiva lo más slim posible y segura. Mismo ejemplo con multi-stages:

```bash
docker  build -t doom-web:multi-stage . -f Dockerfile.multistages
```

Si revisamos las imágenes finales, helloworld:multi-stage y helloworld:prod deberían de tener el mismo peso

```bash
docker images
```

Existen lo que se llaman las imágenes intermedias, que son las que se generan en cada uno de los stages. Para eliminarlas, podemos ejecutar el siguiente comando:

```bash
docker image prune
```

Y como puedes ver, la imagen generada con multi-stage es mucho más pequeña que la generada sin multi-stage.


### 2. A través de Docker CLI
Usando el comando `docker init`


### 3. Usando la extensión de Docker de Visual Studio Code

Basta con  ejecutar Cmd + P > Add Docker Files to Workspace y seleccionar Node.js. Te pedirá que le selecciones el package.json y el puerto que utiliza tu app.
Le diremos que no queremos el archivo de Docker compose, lo dejaremos para más adelante 😃.

### 4. Usando IA, como por ejemplo con Microsoft Edge.

Para ello, tienes que usar Microsoft Edge 😇 y en el lado derecho puedes encontrar el icono de Copilot.

![Microsoft Edge Copilot](imagenes/Microsoft%20Edge%20Copilot.png)

Y en el puedes preguntar por ejemplo cómo crear un Dockerfile para una aplicación en Node.js y te generará un Dockerfile.

![Microsoft Edge Copilot](imagenes/Microsoft%20Edge%20Copilot%20-%20Dockerfile.png)

### 5. Usando GitHub Copilot

GitHub Copilot es una extensión para tu IDE que utiliza IA para ayudarte a programar. Puedes instalarla desde el Visual Studio Code Marketplace.

Una vez la tengas, a diferencia de lo anterior, es capaz de generar el Dockerfile teniendo como contexto el código que tienes en tu editor.

![GitHub Copilot](imagenes/Dockerfile%20usando%20GH%20Copilot.png)