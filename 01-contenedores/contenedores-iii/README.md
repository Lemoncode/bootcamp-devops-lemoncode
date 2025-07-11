# 🐳 Día 3: Contenerización de Aplicaciones

![Docker](./imagenes/Creando%20imagenes%20de%20Docker.jpeg)

## 📋 Agenda

- [🚀 Aplicación de ejemplo](#-aplicación-de-ejemplo)
- [📝 El archivo Dockerfile](#-el-archivo-dockerfile)
  - [✍️ De forma manual](#️-1-de-forma-manual)
  - [⚡ A través de Docker CLI](#-2-a-través-de-docker-cli)
  - [🆚 Usando VS Code](#-3-usando-la-extensión-de-docker-de-visual-studio-code)
  - [🤖 Usando IA (Microsoft Edge)](#-4-usando-ia-como-por-ejemplo-con-microsoft-edge)
  - [🐙 Usando GitHub Copilot](#-5-usando-github-copilot)
- [🚫 El archivo .dockerignore](#-el-archivo-dockerignore)
- [🔨 Generar la imagen en base al Dockerfile](#-generar-la-imagen-en-base-al-dockerfile)
- [▶️ Ejecutar un nuevo contenedor](#️-ejecutar-un-nuevo-contenedor-usando-tu-nueva-imagen)
- [🏗️ Imágenes multi-stage](#️-imágenes-multi-stage)
- [🎯 Docker Bake](#-docker-bake)
- [📦 Publicar nuestras imágenes en Docker Hub](#-publicar-nuestras-imágenes-en-docker-hub)
- [📚 Resumen de lo aprendido](#-resumen-de-lo-aprendido)

---

## 🚀 Aplicación de ejemplo

Para contenerizar una aplicación lo primero que necesitamos es un aplicativo que queramos contenerizar. En este caso, vamos a contenerizar una aplicación en **Node.js** 🟢, que está dentro del directorio `doom-web`. Y antes de contenerizarla es aconsejable ejecutarla en local para comprobar que funciona correctamente.

```bash
cd 01-contenedores/contenedores-iii/doom-web
npm install
npm run test
node server.js
npm run start-dev
```

> [!NOTE]
> 💡 Ejemplo sacado de https://codepen.io/cobra_winfrey/pen/oNOMRav

## 📝 El archivo Dockerfile

Para poder contenerizar cualquier aplicación necesitamos un archivo llamado `Dockerfile`. Este archivo contiene las instrucciones necesarias para construir una imagen de Docker 🐳. Para conseguir este archivo tenemos varias maneras:

### ✍️ 1. De forma manual

En este caso necesitamos conocer los comandos necesarios para construir una imagen de Docker. Puedes encontrar todos los que existen en la [documentación oficial](https://docs.docker.com/engine/reference/builder/). Para este caso, vamos a utilizar un archivo `Dockerfile` que ya está creado en el directorio `doom-web` llamado `Dockerfile`.

## 🚫 El archivo .dockerignore

El archivo `.dockerignore` es un archivo que se utiliza para indicar a Docker qué archivos y carpetas no debe incluir en la imagen. Es muy útil para evitar incluir archivos innecesarios en la imagen, como por ejemplo archivos de logs 📄, archivos temporales ⏱️, etc.

## 🔨 Generar la imagen en base al Dockerfile

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

## ▶️ Ejecutar un nuevo contenedor usando tu nueva imagen:

```bash
docker run -p 8080:3000 doom-web:v1
```

## 🏗️ Imágenes multi-stage

Cuando creamos imágenes de Docker, a veces necesitamos instalar herramientas adicionales para construir nuestra aplicación, como por ejemplo compiladores 🔧, linters 🔍, herramientas de testing 🧪, etc. Sin embargo, estas herramientas no son necesarias en la imagen final, ya que solo necesitamos el binario de nuestra aplicación. Si no lo tenemos en cuenta, nuestra imagen final será más grande de lo necesario.

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

Ahora, si volvemos a generar la imagen, después de que arregles los errores que reporta eslint, comprobarás que ha engordado 📈.

```bash
docker build --tag=doom-web:v2 . -f Dockerfile.dev
docker images
```

En este caso la imagen solo pesa 1 mega más que la anterior, pero si tu aplicación es más grande, la diferencia puede ser mucho mayor.

### 🎭 Multi-stage Builds 

Con multi-stage lo que se hace es utilizar múltiples `FROM` dentro del mismo Dockerfile.
- Cada `FROM` utiliza una imagen base diferente y cada una inicia un nuevo stage
- El último `FROM` produce la imagen final, el resto solo serán intermediarios
- Puedes copiar archivos de un stage a otro, dejando atrás todo lo que no quieres para la imagen final
- La idea es simple: crea imagenes adicionales con las herramientas que necesitas (compiladores, linters, herramientas de testing, etc.) pero que no son necesarias para producción
- El objetivo final es tener una imagen productiva lo más **slim** 🏃‍♀️ posible y **segura** 🔒

Mismo ejemplo con multi-stages:

```bash
docker  build -t doom-web:multi-stage . -f Dockerfile.multistages
```

Si revisamos las imágenes finales, `helloworld:multi-stage` y `helloworld:prod` deberían de tener el mismo peso

```bash
docker images
```

Existen lo que se llaman las imágenes intermedias, que son las que se generan en cada uno de los stages. Para eliminarlas, podemos ejecutar el siguiente comando:

```bash
docker image prune
```

Y como puedes ver, la imagen generada con multi-stage es mucho más pequeña que la generada sin multi-stage. ✨

### ⚡ 2. A través de Docker CLI
Usando el comando `docker init`

### 🆚 3. Usando la extensión de Docker de Visual Studio Code

Basta con ejecutar `Cmd + P > Add Docker Files to Workspace` y seleccionar Node.js. Te pedirá que le selecciones el package.json y el puerto que utiliza tu app.
Le diremos que no queremos el archivo de Docker compose, lo dejaremos para más adelante 😃.

### 🤖 4. Usando IA, como por ejemplo con Microsoft Edge.

Para ello, tienes que usar Microsoft Edge 😇 y en el lado derecho puedes encontrar el icono de Copilot.

![Microsoft Edge Copilot](imagenes/Microsoft%20Edge%20Copilot.png)

Y en el puedes preguntar por ejemplo cómo crear un Dockerfile para una aplicación en Node.js y te generará un Dockerfile.

![Microsoft Edge Copilot](imagenes/Microsoft%20Edge%20Copilot%20-%20Dockerfile.png)

### 🐙 5. Usando GitHub Copilot

GitHub Copilot es una extensión para tu IDE que utiliza IA para ayudarte a programar. Puedes instalarla desde el Visual Studio Code Marketplace.

Una vez la tengas, a diferencia de lo anterior, es capaz de generar el Dockerfile teniendo como contexto el código que tienes en tu editor.

![GitHub Copilot](imagenes/Dockerfile%20usando%20GH%20Copilot.png)

## 🎯 Docker Bake

**Docker Bake** es una característica avanzada de Docker Buildx que te permite definir tu configuración de build usando un archivo declarativo, en lugar de especificar una expresión CLI compleja. También te permite ejecutar múltiples builds de forma concurrente con una sola invocación. 🚀

### 🌟 ¿Por qué usar Docker Bake?

- **📋 Configuración estructurada**: Gestiona builds complejos de manera organizada
- **🔄 Builds concurrentes**: Ejecuta múltiples targets simultáneamente
- **👥 Compartir configuración**: Consistencia entre equipos
- **🎛️ Múltiples formatos**: Soporta HCL, JSON y YAML

### 📝 Ejemplo básico

En lugar de usar un comando largo como:

```bash
docker build \
  -f Dockerfile \
  -t myapp:latest \
  --build-arg foo=bar \
  --no-cache \
  --platform linux/amd64,linux/arm64 \
  .
```

Puedes crear un archivo `docker-bake.hcl`:

```hcl
target "myapp" {
  context = "."
  dockerfile = "Dockerfile"
  tags = ["myapp:latest"]
  args = {
    foo = "bar"
  }
  no-cache = true
  platforms = ["linux/amd64", "linux/arm64"]
}
```

Y ejecutarlo simplemente con:

```bash
docker buildx bake myapp
```

### 🏗️ Ejemplo avanzado con múltiples targets

```hcl
group "default" {
  targets = ["frontend", "backend"]
}

target "frontend" {
  context = "./frontend"
  dockerfile = "frontend.Dockerfile"
  args = {
    NODE_VERSION = "22"
  }
  tags = ["doom-app/frontend:latest"]
}

target "backend" {
  context = "./backend"
  dockerfile = "backend.Dockerfile"
  args = {
    GO_VERSION = "1.24"
  }
  tags = ["doom-app/backend:latest"]
}
```

Para construir ambos targets concurrentemente:

```bash
docker buildx bake
```

### 🎮 Aplicando Bake a nuestro proyecto doom-web

Crear un archivo `docker-bake.hcl` para nuestro proyecto:

```hcl
group "default" {
  targets = ["doom-web-dev", "doom-web-prod"]
}

target "doom-web-dev" {
  context = "."
  dockerfile = "Dockerfile.dev"
  tags = ["doom-web:dev"]
  target = "development"
}

target "doom-web-prod" {
  context = "."
  dockerfile = "Dockerfile"
  tags = ["doom-web:prod", "doom-web:latest"]
  target = "production"
}

target "doom-web-multi" {
  context = "."
  dockerfile = "Dockerfile.multistages"
  tags = ["doom-web:multi-stage"]
  platforms = ["linux/amd64", "linux/arm64"]
}
```

Ejecutar builds específicos:

```bash
# Construir solo producción
docker buildx bake doom-web-prod

# Construir desarrollo y producción
docker buildx bake

# Construir version multi-stage
docker buildx bake doom-web-multi
```

### 💡 Ventajas de usar Bake

1. **🎯 Consistencia**: Todos en el equipo usan la misma configuración
2. **⚡ Eficiencia**: Builds paralelos y reutilización de capas
3. **📖 Legibilidad**: Configuración clara y documentada
4. **🔧 Flexibilidad**: Variables y herencia entre targets
5. **🌐 Multi-plataforma**: Builds para diferentes arquitecturas fácilmente

> [!TIP]
> 💡 **Consejo**: Instala la [extensión de Docker para VS Code](https://marketplace.visualstudio.com/items?itemName=docker.docker) para obtener linting y navegación de código en archivos Bake.

## 📦 Publicar nuestras imágenes en Docker Hub

Para poder publicar nuestras imágenes en Docker Hub, lo primero que necesitamos es tener una cuenta en Docker Hub. Si no tienes una, puedes crear una cuenta gratuita en [https://hub.docker.com/](https://hub.docker.com/) 🆓. Hay un plan gratuito que te permite tener ilimitados repositorios públicos y un repositorio privado.

Una vez que la tengas, necesitas hacer login bien a través del terminal:

```bash
docker login
```

O bien a través de **Docker Desktop** 🖥️.

### 🏷️ Bautizar las imagenes correctamente

Para poder publicar nuestras imágenes en Docker Hub, necesitamos bautizarlas correctamente. El nombre de la imagen debe seguir el siguiente formato:

```
<nombre-de-usuario-o-organización-en-docker-hub>/<nombre-de-la-imagen>:<tag>
```

Por ejemplo, si mi usuario en Docker Hub es `0GiS0` y la imagen se llaman `doom-web` y le quiero poner el tag `v1`, el nombre de la imagen sería:

```
0GiS0/doom-web:v1
```

Si no especificamos un tag, Docker utilizará el tag `latest` por defecto.

Vamos a probarlo:

```bash
docker build -t 0GiS0/doom-web:v1 .
```

Una vez que tenemos la imagen creada, necesitamos hacer push de la imagen a Docker Hub:

```bash
docker push 0GiS0/doom-web:v1
```

Si ahora vamos a Docker Hub, deberíamos ver la imagen que acabamos de subir. 🎉

También puedes añadir a alias a las imágenes existentes para que no tengas que volver a hacer el proceso de build:

```bash
docker tag doom-web:v1 0gis0/doom-web:v2
docker push 0gis0/doom-web:v2
```

### 🎯 Publicar con Docker Bake

También puedes usar Bake para publicar directamente a Docker Hub. Modifica tu archivo `docker-bake.hcl`:

```hcl
target "doom-web-publish" {
  context = "."
  dockerfile = "Dockerfile"
  tags = ["0gis0/doom-web:latest", "0gis0/doom-web:v1.0"]
  platforms = ["linux/amd64", "linux/arm64"]
  output = ["type=registry"]  # Esto hace push automáticamente
}
```

Y ejecuta:

```bash
docker buildx bake doom-web-publish
```

---

## 📚 Resumen de lo aprendido

En este módulo hemos cubierto los aspectos fundamentales de la contenerización de aplicaciones con Docker:

### 🔧 Conceptos clave aprendidos:

1. **📝 Dockerfile**: Archivo de instrucciones para construir imágenes
   - Comandos básicos (`FROM`, `COPY`, `RUN`, `EXPOSE`, etc.)
   - Mejores prácticas de seguridad y optimización

2. **🚫 .dockerignore**: Exclusión de archivos innecesarios
   - Reduce el tamaño de la imagen
   - Mejora la seguridad excluyendo archivos sensibles

3. **🏗️ Multi-stage builds**: Optimización de imágenes
   - Separación entre entorno de build y producción
   - Imágenes más ligeras y seguras
   - Reutilización de capas intermedias

4. **🎯 Docker Bake**: Gestión avanzada de builds
   - Configuración declarativa en HCL/JSON/YAML
   - Builds concurrentes y paralelos
   - Mejor organización para proyectos complejos

5. **📦 Publicación en Docker Hub**: Distribución de imágenes
   - Nomenclatura correcta de imágenes
   - Autenticación y push de imágenes
   - Gestión de tags y versiones

### 🛠️ Herramientas exploradas:

- **Docker CLI**: Comandos básicos de construcción
- **VS Code Extension**: Generación automática de Dockerfiles
- **IA Tools**: Microsoft Edge Copilot y GitHub Copilot
- **Docker Buildx**: Funcionalidades avanzadas con Bake

### ✨ Beneficios obtenidos:

- ⚡ **Eficiencia**: Builds más rápidos y optimizados
- 🔒 **Seguridad**: Imágenes mínimas con menos superficie de ataque
- 👥 **Colaboración**: Configuraciones compartidas y consistentes
- 🌐 **Portabilidad**: Aplicaciones que funcionan en cualquier entorno
- 📈 **Escalabilidad**: Base sólida para orquestación y microservicios

### 🎯 Próximos pasos recomendados:

1. Experimentar con diferentes estrategias de multi-stage
2. Implementar Docker Bake en proyectos reales
3. Explorar Docker Compose para aplicaciones multi-contenedor
4. Aprender sobre orquestación con Kubernetes
5. Profundizar en seguridad de contenedores

> [!SUCCESS]
> 🎉 **¡Felicitaciones!** Ya dominas los fundamentos de la contenerización. Estás listo para el siguiente nivel: orquestación de contenedores.