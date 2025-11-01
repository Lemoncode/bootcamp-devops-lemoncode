# 🐳 Día 3: Contenerización de Aplicaciones

![Docker](./imagenes/Creando%20imagenes%20de%20Docker.jpeg)

¡Hola lemoncoders! 👋 En este tercer día del módulo de contenedores, nos centraremos en la **contenerización de aplicaciones**. Aprenderemos a crear imágenes de Docker 🐳 para nuestras aplicaciones, optimizarlas utilizando técnicas como **multi-stage builds** 🏗️ y publicarlas en Docker Hub 🌐.

## 🎬 Vídeos de la introducción en el campus

Se asume que has visto los siguientes vídeos para comenzar con este módulo:

| # | Tema | Contenido Clave |
|---|------|-----------------|
| 1 | 📘 Teoría | Diseño de imágenes para aplicaciones, buenas prácticas (imagen base mínima, usuario no root, capas ordenadas), estrategias de multi-stage build y diferencias entre entornos dev y prod. |
| 2 | 🛠️ Demo: Ejecutar la aplicación en local | Arranque de la app Node.js (doom-web/) sin Docker, revisión de dependencias (package.json) y endpoints básicos. |
| 3 | 🏷️ Demo: Mi primera contenerización | Una vez que ya sabemos qué vamos a contenerizar, crearemos un Dockerfile básico. |
| 4 | 🌐 Demo: Diferentes Dockerfiles para diferentes cometidos | Separación de Dockerfile (prod), Dockerfile.dev (bind mounts, nodemon) y optimizaciones iniciales. Uso de argumentos y variables de entorno. |
| 5 | 🧪 Demo: Dockerfiles con multistages | Implementación de Dockerfile.multistages para reducir tamaño: stage build (instalación completa y build si aplica) y stage runtime (imagen ligera final solo con artefactos necesarios). |

---

## 🚀 Aplicación de ejemplo

Para contenerizar una aplicación lo primero que necesitamos es un aplicativo que queramos contenerizar. En este caso, vamos a contenerizar una aplicación, un poquito más real que lo que vimos en la clase anterior, donde sólo pegabamos código estático. En este caso vamos a utilizar una aplicación en **Node.js** 🟢, no te preocupes, tampoco muy complicada, que está dentro del directorio `doom-web`. Y antes de contenerizarla es aconsejable ejecutarla en local para comprobar que funciona correctamente.

```bash
cd 01-contenedores/contenedores-iii/doom-web
npm install
npm run test
npm start
npm run start-dev
```

> [!NOTE]
> 💡 Ejemplo sacado de https://codepen.io/cobra_winfrey/pen/oNOMRav

## 📝 El archivo Dockerfile

Para poder contenerizar cualquier aplicación necesitamos un archivo llamado `Dockerfile`. Este archivo contiene las instrucciones necesarias para construir una imagen de Docker 🐳. Para conseguir este archivo tenemos varias maneras:

### ✍️ 1. De forma manual

En este caso necesitamos conocer los comandos necesarios para construir una imagen de Docker. Puedes encontrar todos los que existen en la [documentación oficial](https://docs.docker.com/engine/reference/builder/). Para este caso, vamos a utilizar un archivo `Dockerfile` que ya está creado en el directorio `doom-web` llamado `Dockerfile`.

#### 🚫 El archivo .dockerignore

Aunque es un archivo opcional es más que recomendado el uso del archivo `.dockerignore`. Este archivo se utiliza para indicar a Docker qué archivos y carpetas no debe incluir en la imagen. Es muy útil para evitar incluir archivos innecesarios en la imagen, como por ejemplo archivos de logs 📄, archivos temporales ⏱️, etc.

#### 🔨 Generar la imagen en base al Dockerfile

Una vez que tenemos el archivo `Dockerfile` y el archivo `.dockerignore` podemos generar la imagen de Docker. Para ello, necesitamos ejecutar el siguiente comando:

```bash
docker build -t doom-web:v1 .
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

Para que lo veas con un ejemplo, vamos a instalar todo lo que nuestra aplicación potencialmente puede instalar, para ello modifica el Dockerfile para ejecutar el test con eslint:

```Dockerfile
FROM node:20-alpine

LABEL maintainer="Gisela Torres <gisela.torres@returngis.net>"

# ENV NODE_ENV=production

WORKDIR /usr/src/app

COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]

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
- Cada `FROM` utiliza una imagen base diferente y cada una inicia un nuevo stage o paso en la construcción de la imagen
- El último `FROM` produce la imagen final, el resto solo serán intermediarios
- Puedes copiar archivos de un stage a otro, dejando atrás todo lo que no quieres para la imagen final
- La idea es simple: crea imagenes adicionales con las herramientas que necesitas (compiladores, linters, herramientas de testing, etc.) pero que no son necesarias para producción
- El objetivo final es tener una imagen productiva lo más **fit** 🏃‍♀️ posible y **segura** 🔒

Mismo ejemplo con multi-stages:

```bash
docker  build -t doom-web:multi-stage . -f Dockerfile.multistages
```

Si revisamos las imágenes finales, `doom-web:v1` y `doom-web:multi-stage` deberían de tener el mismo peso

```bash
docker images
```

Existen lo que se llaman las imágenes intermedias, o dangling images, que son las que se generan en cada uno de los stages. Para eliminarlas, podemos ejecutar el siguiente comando:

```bash
docker image prune
```

Y como puedes ver, la imagen generada con multi-stage es mucho más pequeña que la generada sin multi-stage. ✨

## Docker debug

En la última versión de Docker Desktop disponible en la fecha de la última edición de este contenido, la v4.49, se ha puesto a disposición de todos los usuarios la funcionalidad llamada [Docker Debug](https://docs.docker.com/reference/cli/docker/debug/). Esta funcionalidad nos permite depurar nuestras imágenes de Docker de una manera muy sencilla.

```bash
docker debug doom-web:multi-stage
```

## Depurar la construcción de la imagen

Por otro lado, también a día de hoy existe la posibilidad de depurar la construcción de la imagen usando la extensión Docker DX y Visual Studio Code.

---

## 🌍 Crear imágenes multi-arquitectura

A día de hoy, tenemos que preparar nuestras aplicaciones para que se ejecuten en diferentes arquitecturas (Intel/AMD x86_64, ARM, ARM64, etc.). Docker permite crear imágenes que funcionen en múltiples plataformas.

### 🎯 ¿Por qué multi-arquitectura?

- **🖥️ Desarrollo local**: Desarrollo en Mac M1/M2 (ARM64)
- **☁️ Producción en cloud**: Servidores Intel en AWS/GCP/Azure (x86_64)
- **📱 Edge computing**: Dispositivos ARM como Raspberry Pi
- **📦 Compatibilidad**: Una sola imagen para todos

### 🛠️ Requisitos

- Docker Desktop con BuildKit activado (por defecto en versiones recientes)
- Docker Buildx habilitado


Verifica que tienes buildx:

```bash
docker buildx ls
```

>[!NOTE]
>Si no aparece nada, actualiza Docker Desktop.

### 📋 Arquitecturas soportadas

Las más comunes:

| Arquitectura | Alias | Descripción |
|---|---|---|
| `linux/amd64` | x86_64 | Intel/AMD 64-bit |
| `linux/arm64` | aarch64 | ARM 64-bit (Mac M1/M2, algunos servidores) |
| `linux/arm/v7` | armhf | ARM 32-bit (Raspberry Pi 2/3) |
| `linux/386` | i386 | Intel 32-bit (Obsoleto) |
| `linux/ppc64le` | ppc64le | PowerPC 64-bit |
| `windows/amd64` | - | Windows 64-bit |

### 🚀 Crear imagen multi-arquitectura

#### Opción 1: Con docker buildx build

Lo cierto es que crear una imagen multi-arquitectura es tan sencillo como especificar las plataformas que queremos soportar con la opción `--platform`.

```bash
# Construir para múltiples arquitecturas (sin push)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t doom-web:latest \
  --load .
```

#### Opción 2: Con docker buildx build y push automático

```bash
# Construir y pushear a Docker Hub automáticamente
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t tu-usuario/doom-web:latest \
  --push \
  .
```

#### Opción 3: Sin login a Docker Hub (local testing)

```bash
# Para testing local, crear una imagen multi-arch
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t doom-web:multi-arch \
  -o type=oci,dest=./output \
  .
```

### 🏗️ Dockerfile para multi-arquitectura

Para asegurar compatibilidad, usa imágenes base que soporten múltiples arquitecturas:

```dockerfile
# ✅ BUENO: Soporta múltiples arquitecturas
FROM node:20-alpine
FROM python:3.11-slim
FROM golang:1.21

# ❌ MALO: Solo amd64
FROM node:20
FROM ubuntu:22.04
```

### 📝 Ejemplo completo: Multi-stage + Multi-arquitectura

```dockerfile
# syntax=docker/dockerfile:1

# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
RUN npm prune --production

# Stage 2: Runtime
FROM node:20-alpine

WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./

RUN chown -R node:node /app
USER node

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

CMD ["node", "dist/server.js"]
```

Construir:

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t tu-usuario/doom-web:v1.0 \
  --push \
  .
```

### 🔍 Inspeccionar imagen multi-arquitectura

```bash
# Ver las arquitecturas de una imagen en Docker Hub
docker buildx imagetools inspect tu-usuario/doom-web:v1.0

# Output:
# Name:      docker.io/tu-usuario/doom-web:v1.0
# MediaType: application/vnd.docker.distribution.manifest.list.v2+json
# Digest:    sha256:abc123...
#
# Manifests:
#   Name:      tu-usuario/doom-web:v1.0
#   Platform:  linux/amd64
#
#   Name:      tu-usuario/doom-web:v1.0
#   Platform:  linux/arm64
```

### 🎯 Con Docker Bake

Definir en `docker-bake.hcl`:

```hcl
target "doom-web-multiarch" {
  context = "."
  dockerfile = "Dockerfile"
  tags = ["tu-usuario/doom-web:v1.0", "tu-usuario/doom-web:latest"]
  platforms = ["linux/amd64", "linux/arm64"]
  output = ["type=registry"]  # Push automático
}
```

Ejecutar:

```bash
docker buildx bake doom-web-multiarch
```

### 💡 Mejores prácticas

1. **Testa localmente antes de pushear**:
   ```bash
   docker buildx build --platform linux/amd64 -t doom-web:test .
   docker run doom-web:test
   ```

2. **Usa imágenes base slim/alpine**:
   ```dockerfile
   FROM node:20-alpine  # ✅ Multi-arch
   FROM node:20-bookworm  # ❌ Más pesado
   ```

3. **Evita RUN con herramientas específicas de arquitectura**:
   ```dockerfile
   # ❌ MALO
   RUN apt-get install -y x86-64 specific tool
   
   # ✅ BUENO
   RUN if [ "$BUILDPLATFORM" != "$TARGETPLATFORM" ]; then ...; fi
   ```

4. **Build args para arquitectura objetivo**:
   ```dockerfile
   ARG TARGETARCH
   RUN echo "Building for $TARGETARCH"
   ```

---

## 🏗️ Diferentes Builders en Docker

Docker Buildx proporciona múltiples **builders** que podemos usar para optimizar nuestras construcciones.

### 🎯 ¿Qué es un Builder?

Un builder es una instancia del motor de construcción de Docker que ejecuta los builds. Diferentes builders tienen diferentes capacidades y configuraciones:

- **docker-container**: Completo, soporta multi-arch, pero más lento
- **docker**: Nativo del daemon, más rápido pero limitado
- **kubernetes**: Para entornos de Kubernetes
- **remote**: Builders remotos para CI/CD

### 📋 Ver builders disponibles

```bash
docker buildx ls
```

Salida típica:

```
NAME/NODE         DRIVER/ENDPOINT          STATUS  BUILDKIT
mybuilder/*       docker-container         running v0.13.0
  mybuilder0      unix:///var/run/docker.sock    running v0.13.0
desktop-linux    docker                   running v0.12.0
```

### 🆕 Crear un builder personalizado

#### Builder 1: Optimizado para velocidad (docker-container)

```bash
docker buildx create \
  --name fast-builder \
  --driver docker-container \
  --use \
  --bootstrap
```

Este builder:
- Ejecuta en un contenedor separado
- Soporta multi-arquitectura
- Mejor rendimiento en builds complejos

#### Builder 2: Builder remoto para CI/CD

```bash
docker buildx create \
  --name ci-builder \
  --driver docker-container \
  --use
```

#### Builder 3: Kubectl (para Kubernetes)

```bash
docker buildx create \
  --name k8s-builder \
  --driver kubernetes \
  --use
```

Requiere estar conectado a un cluster de Kubernetes:

```bash
docker buildx create \
  --name k8s-builder \
  --driver kubernetes \
  --allow-insecure-entitlement security.insecure \
  --use
```

### 🎛️ Gestionar builders

```bash
# Listar todos los builders
docker buildx ls

# Ver información detallada
docker buildx du

# Usar un builder específico
docker buildx use fast-builder

# Inspeccionar builder
docker buildx inspect fast-builder

# Eliminar builder
docker buildx rm fast-builder

# Detener builder
docker buildx stop fast-builder

# Reiniciar builder
docker buildx start fast-builder
```

### 🚀 Usar builders específicos en builds

```bash
# Usar el builder por defecto
docker build -t doom-web:v1 .

# Con buildx y builder específico
docker buildx build \
  --builder fast-builder \
  -t doom-web:v1 \
  .

# Multi-arquitectura con builder específico
docker buildx build \
  --builder k8s-builder \
  --platform linux/amd64,linux/arm64 \
  -t tu-usuario/doom-web:v1 \
  --push \
  .
```

### 📊 Estadísticas de builders

```bash
# Ver uso de disco de builders
docker buildx du

# Output:
# ID                           RECLAIMABLE SIZE
# mybuilder0                   5.2GB    false
# desktop-linux                2.3GB    false

# Limpiar caché del builder
docker buildx prune --all --builder fast-builder
```

### 🎮 Ejemplo práctico: Builders en docker-bake.hcl

```hcl
# Definir builder a usar
variable "BUILDER" {
  default = "fast-builder"
}

target "doom-web-prod" {
  context = "."
  dockerfile = "Dockerfile"
  tags = ["doom-web:prod"]
  builder = var.BUILDER
  output = ["type=docker"]
}

target "doom-web-multiarch" {
  context = "."
  dockerfile = "Dockerfile"
  tags = ["tu-usuario/doom-web:latest"]
  platforms = ["linux/amd64", "linux/arm64"]
  builder = "k8s-builder"  # Usar builder específico
  output = ["type=registry"]
}
```

Ejecutar:

```bash
# Usar builder por defecto
docker buildx bake doom-web-prod

# Usar builder específico
docker buildx bake --builder fast-builder doom-web-prod

# Multi-arquitectura con builder remoto
docker buildx bake doom-web-multiarch
```

### 🔍 Optimizaciones por builder

| Builder | Velocidad | Multi-arch | CI/CD | Cache persistente |
|---------|-----------|-----------|-------|-------------------|
| docker | ⚡⚡⚡ | ❌ | ❌ | ⚠️ |
| docker-container | ⚡⚡ | ✅ | ✅ | ✅ |
| kubernetes | ⚡ | ✅ | ✅ | ✅ |
| remote | ⚡ | ✅ | ✅ | ✅ |

---

## 🔍 Docker Build Checks

**Docker Build Checks** es una característica introducida en Dockerfile 1.8 que te permite validar tu configuración de build y realizar una serie de verificaciones antes de ejecutar tu build. Es como un **linter avanzado** para tu Dockerfile y opciones de build, o un modo de **dry-run** para builds. 🎯

### 🌟 ¿Por qué usar Build Checks?

- **✅ Validación temprana**: Detecta problemas antes de ejecutar el build
- **📋 Mejores prácticas**: Asegura que tu Dockerfile sigue las recomendaciones actuales
- **🚫 Anti-patrones**: Identifica patrones problemáticos en tu configuración
- **🔒 Seguridad**: Ayuda a detectar configuraciones inseguras
- **⚡ Eficiencia**: Ahorra tiempo evitando builds fallidos

### 🛠️ Requisitos

- **Buildx**: versión 0.15.0 o posterior
- **docker/build-push-action**: versión 6.6.0 o posterior
- **docker/bake-action**: versión 5.6.0 o posterior

### 🚀 Uso básico

Por defecto, los checks se ejecutan automáticamente cuando haces un build:

```bash
docker build .
```

**Salida de ejemplo:**
```
[+] Building 3.5s (11/11) FINISHED
...

1 warning found (use --debug to expand):
  - JSONArgsRecommended: JSON arguments recommended for CMD to prevent unintended behavior related to OS signals (line 7)
```

### 🔍 Verificar sin construir

Para ejecutar solo los checks sin construir la imagen:

```bash
docker build --check .
```

**Ejemplo de salida detallada:**
```
[+] Building 1.5s (5/5) FINISHED
=> [internal] connecting to local controller
=> [internal] load build definition from Dockerfile
=> => transferring dockerfile: 253B

JSONArgsRecommended - https://docs.docker.com/go/dockerfile/rule/json-args-recommended/
JSON arguments recommended for ENTRYPOINT/CMD to prevent unintended behavior related to OS signals
Dockerfile:7
--------------------
5 |
6 |     COPY index.js .
7 | >>> CMD node index.js
8 |
--------------------
```

### 📝 Ejemplo práctico con nuestro proyecto doom-web

Vamos a probar los checks con nuestro Dockerfile actual:

```bash
cd doom-web
docker build --check .
```

Si hay warnings, puedes ver más detalles con:

```bash
docker --debug build --check .
```

### ⚙️ Configuración avanzada

#### 🚨 Fallar el build en violaciones

Puedes configurar que el build falle cuando se encuentren violaciones usando la directiva `check=error=true`:

```dockerfile
# syntax=docker/dockerfile:1
# check=error=true

FROM node:20-alpine
COPY package*.json ./
RUN npm install
COPY . .
CMD npm start  # Esto generará un warning que ahora será un error
```

También puedes configurarlo vía CLI:

```bash
docker build --build-arg "BUILDKIT_DOCKERFILE_CHECK=error=true" .
```

#### 🙈 Omitir checks específicos

Para saltar checks específicos:

```dockerfile
# syntax=docker/dockerfile:1
# check=skip=JSONArgsRecommended,StageNameCasing

FROM alpine AS BASE_STAGE
CMD echo "Hello, world!"
```

O vía CLI:

```bash
docker build --build-arg "BUILDKIT_DOCKERFILE_CHECK=skip=JSONArgsRecommended" .
```

Para saltar todos los checks:

```dockerfile
# syntax=docker/dockerfile:1
# check=skip=all
```

#### 🧪 Checks experimentales

Para habilitar checks experimentales:

```bash
docker build --build-arg "BUILDKIT_DOCKERFILE_CHECK=experimental=all" .
```

O en el Dockerfile:

```dockerfile
# syntax=docker/dockerfile:1
# check=experimental=all
```

#### 🔧 Combinando parámetros

Puedes combinar múltiples configuraciones separándolas con punto y coma:

```dockerfile
# syntax=docker/dockerfile:1
# check=skip=JSONArgsRecommended;error=true;experimental=all
```

### 🎮 Aplicando checks a nuestro proyecto doom-web

Crear un `Dockerfile.checked` que siga las mejores prácticas:

```dockerfile
# syntax=docker/dockerfile:1
# check=error=true

FROM node:20-alpine AS base

LABEL maintainer="Gisela Torres <gisela.torres@returngis.net>"

WORKDIR /usr/src/app

# Mejores prácticas para el manejo de dependencias
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copiar archivos de la aplicación
COPY . .

# Exponer puerto
EXPOSE 3000

# Usar user no-root por seguridad
RUN chown -R node:node /usr/src/app
USER node

# Usar formato JSON para CMD (evita warnings)
CMD ["npm", "start"]
```

Probar los checks:

```bash
docker build --check -f Dockerfile.checked .
```

### 🎯 Integración con Docker Bake

También puedes usar checks con Docker Bake añadiendo la configuración en tu `docker-bake.hcl`:

```hcl
target "doom-web-checked" {
  context = "."
  dockerfile = "Dockerfile.checked"
  tags = ["doom-web:checked"]
  args = {
    BUILDKIT_DOCKERFILE_CHECK = "error=true"
  }
}

target "doom-web-check-only" {
  context = "."
  dockerfile = "Dockerfile"
  args = {
    BUILDKIT_DOCKERFILE_CHECK = "error=true;experimental=all"
  }
  output = ["type=cacheonly"]
}
```

Ejecutar:

```bash
# Build con checks estrictos
docker buildx bake doom-web-checked

# Solo ejecutar checks sin build
docker buildx build --check -f Dockerfile.checked .
```

### 🔧 Checks más comunes

| Check | Descripción | Ejemplo problemático | Solución |
|-------|-------------|---------------------|----------|
| **JSONArgsRecommended** | CMD/ENTRYPOINT deberían usar formato JSON | `CMD npm start` ❌ | `CMD ["npm", "start"]` ✅ |
| **StageNameCasing** | Nombres de stage deberían estar en minúsculas | `FROM alpine AS BASE_STAGE` ❌ | `FROM alpine AS base` ✅ |
| **FromAsCasing** | La palabra AS debería estar en mayúsculas | `FROM alpine as base` ❌ | `FROM alpine AS base` ✅ |
| **NoEmptyCommand** | Comandos no deberían estar vacíos | `RUN` ❌ | `RUN echo "hello"` ✅ |
| **UndefinedVariable** | Variables no definidas en ARG | `RUN echo $UNDEFINED` ❌ | `ARG MY_VAR` y luego usar ✅ |
| **SeeminglyEmptyBase** | Imagen base muy grande | `FROM ubuntu` ❌ | `FROM alpine` ✅ |
| **OfficialRepositoriesDiscouraged** | Usar registros que no sean oficiales | - | Usar tags específicos |

### 📊 Integración con CI/CD

#### GitHub Actions

```yaml
name: Docker Build with Checks
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Run build checks
        uses: docker/build-push-action@v6.6.0
        with:
          context: .
          push: false
          build-args: |
            BUILDKIT_DOCKERFILE_CHECK=error=true
```

Los checks aparecerán como anotaciones en las pull requests de GitHub! 📝

### 💡 Mejores prácticas

1. **🎯 Usa checks desde el inicio**: Integra checks en tu workflow de desarrollo
2. **⚠️ Trata warnings como errores**: Usa `check=error=true` en producción
3. **📋 Documenta excepciones**: Si skips checks, documenta por qué
4. **🔄 Actualiza regularmente**: Los checks evolucionan con las mejores prácticas
5. **👥 Estandariza en equipo**: Usa la misma configuración en todo el proyecto

### 🎯 Ejercicio práctico

1. Ejecuta checks en nuestro Dockerfile actual:
   ```bash
   cd doom-web
   docker build --check .
   ```

2. Corrige los warnings encontrados creando un `Dockerfile.best-practices`

3. Añade la configuración a tu `docker-bake.hcl`:
   ```hcl
   target "doom-web-validated" {
     context = "."
     dockerfile = "Dockerfile.best-practices"
     tags = ["doom-web:validated"]
     args = {
       BUILDKIT_DOCKERFILE_CHECK = "error=true"
     }
   }
   ```

4. Prueba el build con checks estrictos:
   ```bash
   docker buildx bake doom-web-validated
   ```

> [!TIP]
> 💡 **Consejo**: Instala la [extensión de Docker para VS Code](https://marketplace.visualstudio.com/items?itemName=docker.docker) para obtener linting en tiempo real de tu Dockerfile.

---

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

Por ejemplo, si mi usuario en Docker Hub es `0GiS0` y la imagen se llama `doom-web` y le quiero poner el tag `v1`, el nombre de la imagen sería:

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

También puedes añadir alias a las imágenes existentes para que no tengas que volver a hacer el proceso de build:

```bash
docker tag doom-web:v1 0gis0/doom-web:v2
docker push 0gis0/doom-web:v2
```

### 🏷️ Nomenclatura de tags

Es una buena práctica usar tags significativos:

```bash
# Tags por versión
docker build -t tu-usuario/doom-web:1.0.0 .
docker build -t tu-usuario/doom-web:1.0 .
docker build -t tu-usuario/doom-web:latest .

# Tags por fecha
docker build -t tu-usuario/doom-web:2024-11-01 .

# Tags por ambiente
docker build -t tu-usuario/doom-web:prod .
docker build -t tu-usuario/doom-web:staging .
docker build -t tu-usuario/doom-web:dev .

# Tags descriptivos
docker build -t tu-usuario/doom-web:v1.0-alpine .
docker build -t tu-usuario/doom-web:v1.0-ubuntu .
```

### 🔗 Crear alias de imágenes

```bash
# Crear alias sin rebuildar
docker tag doom-web:v1 tu-usuario/doom-web:latest
docker tag doom-web:v1 tu-usuario/doom-web:stable

# Push de todos los alias
docker push tu-usuario/doom-web:v1
docker push tu-usuario/doom-web:latest
docker push tu-usuario/doom-web:stable
```

### 📊 Ver información de push

```bash
# Ver progreso detallado
docker push -a tu-usuario/doom-web

# Ver historial de push
docker history tu-usuario/doom-web:v1
```

### 🎯 Publicar con Docker Bake

También puedes usar Bake para publicar directamente a Docker Hub. Modifica tu archivo `docker-bake.hcl`:

```hcl
target "doom-web-publish" {
  context = "."
  dockerfile = "Dockerfile"
  tags = ["tu-usuario/doom-web:latest", "tu-usuario/doom-web:v1.0"]
  platforms = ["linux/amd64", "linux/arm64"]
  output = ["type=registry"]  # Esto hace push automáticamente
}

target "doom-web-multiarch-publish" {
  context = "."
  dockerfile = "Dockerfile.multistages"
  tags = [
    "tu-usuario/doom-web:v1.0-multiarch",
    "tu-usuario/doom-web:latest-multiarch"
  ]
  platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7"]
  output = ["type=registry"]
}

target "doom-web-dev-publish" {
  context = "."
  dockerfile = "Dockerfile.dev"
  tags = ["tu-usuario/doom-web:dev"]
  output = ["type=registry"]
}
```

Y ejecuta:

```bash
# Publicar versión de producción
docker buildx bake doom-web-publish

# Publicar con multi-arquitectura
docker buildx bake doom-web-multiarch-publish

# Publicar versión de desarrollo
docker buildx bake doom-web-dev-publish

# Publicar todo de una vez
docker buildx bake
```

### 🔐 Registros privados

Si quieres usar un registro privado:

```bash
# Login a registro privado
docker login registro-privado.com

# Tag para registro privado
docker build -t registro-privado.com/doom-web:v1 .

# Push a registro privado
docker push registro-privado.com/doom-web:v1
```

### 📋 Verificar imagen en Docker Hub

```bash
# Ver imagen publicada
docker pull tu-usuario/doom-web:v1

# Ejecutar desde Docker Hub
docker run -p 3000:3000 tu-usuario/doom-web:v1

# Ver las capas de la imagen en Docker Hub
docker inspect tu-usuario/doom-web:v1 | jq '.RootFS'
```

---

### ⚡ 2. Usando `docker init` en Docker CLI

El comando `docker init` es una herramienta interactiva que te ayuda a generar un Dockerfile y otros archivos necesarios para contenerizar tu aplicación sin tener que escribir todo desde cero.

#### 🎯 Ventajas de usar `docker init`

- **🚀 Rápido**: Genera un Dockerfile completo en segundos
- **🎓 Educativo**: Te enseña las mejores prácticas automáticamente
- **🔧 Inteligente**: Detecta el tipo de proyecto (Node, Python, Go, etc.)
- **✅ Validado**: Produce Dockerfiles que siguen estándares

#### 📋 Paso a paso

Primero, asegúrate de que tienes Docker 4.18.0 o superior:

```bash
docker --version
```

Ahora, dentro del directorio de tu proyecto:

```bash
# Navega a la carpeta de tu proyecto
cd doom-web

# Ejecuta docker init
docker init
```

Se te hará una serie de preguntas interactivas:

```
Welcome to the Docker Init CLI!

This utility will walk you through creating the necessary Docker files
for your project as simple as possible.

Looking at your project files, we recommend the following configuration:

? Include optional metadata (author, description)? [y/N] y
? Your name: Your Name
? Description: A Doom-inspired web application
? Detected language: node. Is this correct? [Y/n] Y
? Port to expose: 3000
```

Esto generará:

- `Dockerfile` - Para producción
- `.dockerignore` - Archivos a ignorar
- `compose.yaml` - Para desarrollo con Docker Compose (opcional)

#### 📋 Resultado de `docker init`

El Dockerfile generado será similar a:

```dockerfile
# syntax=docker/dockerfile:1

ARG NODE_VERSION=20

FROM node:${NODE_VERSION}-alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production

COPY . .

EXPOSE 3000

USER node

CMD ["npm", "start"]
```

#### �️ Siguiente paso

Una vez generados los archivos, puedes construir la imagen:

```bash
docker build -t doom-web:init .
docker run -p 3000:3000 doom-web:init
```

> [!TIP]
> 💡 **Consejo**: El archivo `compose.yaml` generado es perfecto como punto de partida para desarrollo local con volúmenes y bind mounts.

---

### �🆚 3. Usando la extensión de Docker de Visual Studio Code

La extensión oficial de Docker para VS Code ofrece una forma visual e interactiva de generar Dockerfiles.

#### 🔧 Instalación

1. Abre VS Code
2. Ve a Extensions (Ctrl+Shift+X en Linux/Windows, Cmd+Shift+X en Mac)
3. Busca "Docker"
4. Instala la extensión oficial de Docker

#### 📝 Generación automática

Una vez instalada, haz lo siguiente:

1. Abre la paleta de comandos: `Cmd + P` (Mac) o `Ctrl + P` (Linux/Windows)
2. Escribe: `Add Docker Files to Workspace`
3. Selecciona el comando

Se abrirá un asistente:

```
Select Application Platform
├─ Node
├─ Python
├─ Go
├─ .NET
└─ Java
```

Para nuestro caso, selecciona **Node**.

#### 🎯 Configuración del asistente

El asistente te pedirá:

- **Package.json location**: Selecciona el `package.json` de tu proyecto
- **Port**: El puerto que expone tu aplicación (3000 para doom-web)
- **Include optional Docker Compose file**: Selecciona NO por ahora (lo veremos después)
- **Include Docker Compose file for debugging**: NO

#### 📦 Archivos generados

Generará automáticamente:

- `Dockerfile` (producción)
- `Dockerfile.dev` (desarrollo)
- `.dockerignore`

El Dockerfile tendrá esta estructura:

```dockerfile
FROM node:20-alpine

ENV NODE_ENV=production

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["node", "server.js"]
```

#### 🚀 Próximas acciones

```bash
# Construir la imagen
docker build -t doom-web:vscode .

# Ejecutar el contenedor
docker run -p 3000:3000 doom-web:vscode
```

---

### 🤖 4. Usando `docker ai` - AI Gordon 🦾

Docker ha introducido **Docker AI**, un agente de IA que te ayuda a generar Dockerfiles inteligentes usando tecnología de IA.

#### 📋 Requisitos

- **Docker Desktop 4.27.0+** o superior
- Haber iniciado sesión con tu cuenta Docker
- Acceso a Docker AI habilitado en Settings > Beta features

#### 🔐 Configurar Docker AI

1. Abre Docker Desktop
2. Ve a **Settings > Beta features**
3. Habilita **"Use Docker AI"**
4. Asegúrate de haber hecho login con tu cuenta Docker

#### 🚀 Uso básico

Desde la terminal, en el directorio de tu proyecto:

```bash
# Solicitar generación de Dockerfile
docker ai "Quiero contenerizar una aplicación Node.js con Express que expone el puerto 3000"
```

O de forma más específica:

```bash
docker ai "Crea un Dockerfile para una aplicación Node.js con:
- Puerto 3000
- Soporte para desarrollo y producción
- Usuario no-root
- Multi-stage build
- Node 20-alpine"
```

#### 📤 Resultados

Docker AI te mostrará:

```
Based on your requirements, here's a recommended Dockerfile:

FROM node:20-alpine as builder
...

FROM node:20-alpine as runtime
...

Tips:
- Consider using .dockerignore to exclude files
- Use health checks for production
- Keep your base images updated
```

#### 💡 Ejemplos de prompts útiles

```bash
# Generar Dockerfile optimizado
docker ai "Optimiza este Dockerfile para producción"

# Debuggear problemas
docker ai "Mi imagen Docker pesa 500MB, ¿cómo la puedo reducir?"

# Seguridad
docker ai "¿Cuáles son las prácticas de seguridad que debería implementar en mi Dockerfile?"

# Multi-arquitectura
docker ai "Necesito soportar linux/amd64 y linux/arm64. ¿Cómo lo hago?"
```

#### ⚙️ Configuración avanzada

Puedes hacer prompts más complejos:

```bash
docker ai "
Crea un Dockerfile multi-stage que:
1. En el stage de build: instale todas las dependencias y ejecute tests
2. En el stage de desarrollo: tenga nodemon y herramientas de debug
3. En el stage de producción: solo lo necesario para ejecutar la app
4. Utilice variables de entorno para NODE_ENV
5. Implemente health checks
"
```

> [!NOTE]
> 💡 Docker AI está en fase beta y requiere conexión a internet.

### 🌐 5. Usando Microsoft Edge Copilot

Microsoft Edge incluye **Copilot**, una herramienta de IA integrada que puede ayudarte a generar Dockerfiles.

#### 🔧 Requisitos

- Tener **Microsoft Edge** instalado
- Estar en una versión reciente de Edge
- Tener la interfaz de Copilot activa

#### 🚀 Pasos

1. **Abre tu proyecto en VS Code** dentro de Edge (o el navegador)

2. **Abre Copilot** en Edge:
   - En la parte derecha del navegador, busca el icono de Copilot 🤖
   - O presiona `Ctrl+Shift+Y` (Windows) / `Cmd+Shift+Y` (Mac)

3. **Selecciona tu archivo** que quieres contenerizar en VS Code

4. **Realiza tu pregunta en Copilot**:
   ```
   ¿Puedes crearme un Dockerfile para este proyecto Node.js?
   ```

5. **Copilot generará** un Dockerfile personalizado basado en el contenido de tu proyecto

#### 📋 Ejemplo de interacción

**Tu pregunta:**
```
Crea un Dockerfile para contenerizar esta aplicación Node.js.
La app usa Express, debe exponer el puerto 3000, y necesito
una versión de desarrollo y otra de producción.
```

**Respuesta de Copilot:**
```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

#### 🎯 Ventajas

- 🔄 **Contexto visual**: Ve el código que necesita ser contenerizado
- 💬 **Conversacional**: Puedes hacer seguimientos y ajustes
- 🎨 **Explicaciones**: Te explica qué hace cada línea
- 🔗 **Integración**: Acceso directo desde el navegador

#### 💡 Mejores prácticas para prompts

```markdown
Pregunta bien estructurada:
- QUÉ: "Genera un Dockerfile para una app Node.js"
- DETALLES: "Usa node:20-alpine como base"
- REQUISITOS: "Soporta puerto 3000, incluye health check"
- OBJETIVO: "Optimizar para producción"
```

---

### 🐙 6. Usando GitHub Copilot

GitHub Copilot es una extensión de IA para tu IDE que genera código con contexto completo de tu editor.

#### 🔧 Instalación

1. Abre VS Code
2. Ve a Extensions (Cmd+Shift+X)
3. Busca "GitHub Copilot"
4. Instala la extensión oficial de GitHub
5. Inicia sesión con tu cuenta GitHub

#### 🎯 Generar Dockerfile

**Opción 1: Sugerencias automáticas**

1. Crea un archivo llamado `Dockerfile`
2. Escribe `FROM` y presiona Tab
3. GitHub Copilot sugerirá el resto automáticamente

**Opción 2: Chat de Copilot**

1. Abre la paleta de comandos: `Cmd + Shift + P`
2. Escribe: `GitHub Copilot: Open Copilot Chat`
3. Escribe tu pregunta:
   ```
   Crea un Dockerfile multi-stage para una app Node.js que:
   - Use node:20-alpine
   - Tenga stage de build y stage de runtime
   - Ejecute tests en el build
   - Sea seguro (usuario no-root)
   ```

#### 📝 Ejemplo de generación

**Inicio del Dockerfile:**
```dockerfile
FROM node:20-alpine
```

Presiona Tab y Copilot completará:

```dockerfile
FROM node:20-alpine

LABEL maintainer="Your Name"

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

RUN chown -R node:node /app

USER node

CMD ["npm", "start"]
```

#### 💎 Ventajas únicas de GitHub Copilot

- 🧠 **Contexto del proyecto**: Entiende tu código existente
- 📚 **Aprendizaje**: Aprende patrones de tu codebase
- 🤖 **Predicción**: Anticipa lo que necesitarás
- 🔄 **Iterativo**: Puedes refinarlo línea a línea
- 👥 **Explicaciones**: Explica su código generado

#### 🎯 Ejemplo práctico: Multi-stage con Copilot

1. Abre Chat de Copilot
2. Pregunta:
   ```
   Create a multi-stage Dockerfile that:
   1. Builds and tests the Node app in one stage
   2. Runs only the app in a minimal Alpine image
   3. Uses non-root user
   4. Includes health checks
   ```
3. Copilot generará:

```dockerfile
# syntax=docker/dockerfile:1
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run test
RUN npm run build

FROM node:20-alpine

WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
RUN npm ci --only=production

RUN chown -R node:node /app
USER node

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node healthcheck.js

EXPOSE 3000
CMD ["npm", "start"]
```

#### 🚀 Comandos de Copilot Chat

```bash
# Refine una sugerencia
/fix "Error en la línea X"

# Explicar el código
/explain

# Generar tests
/test

# Optimizar
/optimize
```

---

## 🎯 Docker Bake - Definir configuraciones como código

**Docker Bake** es una característica avanzada de Docker Buildx que te permite definir tu configuración de build usando un archivo declarativo, en lugar de especificar una expresión CLI compleja. También te permite ejecutar múltiples builds de forma concurrente con una sola invocación. 🚀

### 🌟 ¿Por qué usar Docker Bake?

- **📋 Configuración estructurada**: Gestiona builds complejos de manera organizada
- **🔄 Builds concurrentes**: Ejecuta múltiples targets simultáneamente
- **👥 Compartir configuración**: Consistencia entre equipos
- **🎛️ Múltiples formatos**: Soporta HCL, JSON y YAML
- **⚙️ Variables**: Reutilización de configuración
- **📦 Grupos**: Agrupar builds relacionados

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

### 🛠️ Sintaxis de Docker Bake

#### Estructura básica en HCL:

```hcl
# Variables
variable "REGISTRY" {
  default = "docker.io"
}

variable "USER" {
  default = "tu-usuario"
}

# Definir un grupo de targets
group "default" {
  targets = ["app-prod", "app-dev"]
}

# Definir un target (objetivo de build)
target "app-prod" {
  context = "."
  dockerfile = "Dockerfile"
  tags = ["${REGISTRY}/${USER}/app:latest"]
  args = {
    NODE_ENV = "production"
  }
  platforms = ["linux/amd64"]
  output = ["type=registry"]  # Push automático
}

target "app-dev" {
  context = "."
  dockerfile = "Dockerfile.dev"
  tags = ["${REGISTRY}/${USER}/app:dev"]
  platforms = ["linux/amd64"]
  output = ["type=docker"]  # Load local
}
```

Ejecutar:

```bash
# Ejecutar el grupo default (prod + dev)
docker buildx bake

# Ejecutar solo un target
docker buildx bake app-prod

# Ejecutar con variables personalizadas
docker buildx bake --set "*.tags=tu-usuario/app:v2.0"
```

### 🏗️ Ejemplo avanzado con múltiples targets

```hcl
# Variables globales
variable "REGISTRY" {
  default = "docker.io"
}

variable "IMAGE_NAME" {
  default = "doom-web"
}

variable "VERSION" {
  default = "v1.0.0"
}

# Grupos de builds
group "default" {
  targets = ["doom-web-dev", "doom-web-prod"]
}

group "multi-arch" {
  targets = ["doom-web-prod-multiarch"]
}

group "all" {
  targets = ["doom-web-dev", "doom-web-prod", "doom-web-prod-multiarch", "doom-web-validated"]
}

# Configuración común (herencia)
target "_common" {
  dockerfile = "Dockerfile"
  labels = {
    "org.opencontainers.image.title" = "Doom Web"
    "org.opencontainers.image.version" = var.VERSION
    "org.opencontainers.image.authors" = "Your Name"
  }
}

# Target: Desarrollo
target "doom-web-dev" {
  inherits = ["_common"]
  dockerfile = "Dockerfile.dev"
  context = "."
  tags = ["${REGISTRY}/${IMAGE_NAME}:dev"]
  args = {
    NODE_ENV = "development"
  }
  target = "development"
  output = ["type=docker"]
}

# Target: Producción simple
target "doom-web-prod" {
  inherits = ["_common"]
  context = "."
  tags = [
    "${REGISTRY}/${IMAGE_NAME}:latest",
    "${REGISTRY}/${IMAGE_NAME}:${VERSION}"
  ]
  args = {
    NODE_ENV = "production"
  }
  platforms = ["linux/amd64"]
  output = ["type=docker"]
}

# Target: Producción multi-arquitectura
target "doom-web-prod-multiarch" {
  inherits = ["_common"]
  context = "."
  tags = [
    "${REGISTRY}/${IMAGE_NAME}:latest-multiarch",
    "${REGISTRY}/${IMAGE_NAME}:${VERSION}-multiarch"
  ]
  args = {
    NODE_ENV = "production"
  }
  platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7"]
  output = ["type=registry"]  # Push automático
}

# Target: Validada con checks
target "doom-web-validated" {
  inherits = ["_common"]
  context = "."
  dockerfile = "Dockerfile.checked"
  tags = ["${REGISTRY}/${IMAGE_NAME}:validated"]
  args = {
    NODE_ENV = "production"
    BUILDKIT_DOCKERFILE_CHECK = "error=true"
  }
  output = ["type=docker"]
}

# Target: Multistage optimizado
target "doom-web-optimized" {
  inherits = ["_common"]
  context = "."
  dockerfile = "Dockerfile.multistages"
  tags = [
    "${REGISTRY}/${IMAGE_NAME}:optimized",
    "${REGISTRY}/${IMAGE_NAME}:${VERSION}-optimized"
  ]
  platforms = ["linux/amd64", "linux/arm64"]
  output = ["type=registry"]
  cache-from = ["type=registry,ref=${REGISTRY}/${IMAGE_NAME}:buildcache"]
  cache-to = ["type=registry,ref=${REGISTRY}/${IMAGE_NAME}:buildcache,mode=max"]
}
```

Para construir:

```bash
# Construir grupo default (dev + prod)
docker buildx bake

# Construir solo multi-arquitectura
docker buildx bake multi-arch

# Construir todos los targets
docker buildx bake all

# Construir con variable personalizada
docker buildx bake --set "VERSION=v2.0.0"

# Construir un target específico
docker buildx bake doom-web-optimized
```

### 🎮 Aplicando Bake a nuestro proyecto doom-web (Ejemplo completo)

Crear un archivo `docker-bake.hcl`:

```hcl
# ============================================
# VARIABLES
# ============================================

variable "REGISTRY" {
  default = "docker.io"
}

variable "USER" {
  default = "0gis0"  # Cambia por tu usuario Docker Hub
}

variable "VERSION" {
  default = "1.0.0"
}

variable "NODE_VERSION" {
  default = "20"
}

# ============================================
# CONFIGURACIÓN COMÚN
# ============================================

target "_base" {
  dockerfile = "Dockerfile"
  context = "."
  labels = {
    "org.opencontainers.image.title" = "Doom Web"
    "org.opencontainers.image.version" = var.VERSION
    "org.opencontainers.image.url" = "https://github.com/tu-repo/doom-web"
  }
}

# ============================================
# GRUPOS
# ============================================

group "default" {
  targets = ["doom-web-prod"]
}

group "dev" {
  targets = ["doom-web-dev"]
}

group "ci" {
  targets = ["doom-web-prod-multiarch", "doom-web-validated"]
}

group "all" {
  targets = [
    "doom-web-dev",
    "doom-web-prod",
    "doom-web-prod-multiarch",
    "doom-web-validated",
    "doom-web-optimized"
  ]
}

# ============================================
# TARGETS
# ============================================

# 1. Desarrollo local
target "doom-web-dev" {
  inherits = ["_base"]
  dockerfile = "Dockerfile.dev"
  tags = ["doom-web:dev"]
  args = {
    NODE_ENV = "development"
    NODE_VERSION = var.NODE_VERSION
  }
  target = "development"
  platforms = ["linux/amd64"]
  output = ["type=docker"]
}

# 2. Producción local (para testing)
target "doom-web-prod" {
  inherits = ["_base"]
  dockerfile = "Dockerfile"
  tags = ["doom-web:prod", "doom-web:latest"]
  args = {
    NODE_ENV = "production"
    NODE_VERSION = var.NODE_VERSION
  }
  platforms = ["linux/amd64"]
  output = ["type=docker"]
}

# 3. Producción multi-arquitectura (para CI/CD)
target "doom-web-prod-multiarch" {
  inherits = ["_base"]
  dockerfile = "Dockerfile"
  tags = [
    "${REGISTRY}/${USER}/doom-web:${VERSION}",
    "${REGISTRY}/${USER}/doom-web:latest"
  ]
  args = {
    NODE_ENV = "production"
    NODE_VERSION = var.NODE_VERSION
  }
  platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7"]
  output = ["type=registry"]
  cache-from = ["type=registry,ref=${REGISTRY}/${USER}/doom-web:buildcache"]
  cache-to = ["type=registry,ref=${REGISTRY}/${USER}/doom-web:buildcache,mode=max"]
}

# 4. Validada con checks
target "doom-web-validated" {
  inherits = ["_base"]
  dockerfile = "Dockerfile.checked"
  tags = ["${REGISTRY}/${USER}/doom-web:${VERSION}-validated"]
  args = {
    NODE_ENV = "production"
    BUILDKIT_DOCKERFILE_CHECK = "error=true"
  }
  platforms = ["linux/amd64", "linux/arm64"]
  output = ["type=registry"]
}

# 5. Multi-stage optimizada
target "doom-web-optimized" {
  inherits = ["_base"]
  dockerfile = "Dockerfile.multistages"
  tags = [
    "${REGISTRY}/${USER}/doom-web:${VERSION}-slim",
    "${REGISTRY}/${USER}/doom-web:slim"
  ]
  platforms = ["linux/amd64", "linux/arm64"]
  output = ["type=registry"]
}

# 6. Frontend (hipotético)
target "doom-web-frontend" {
  inherits = ["_base"]
  dockerfile = "frontend/Dockerfile"
  context = "frontend"
  tags = ["${REGISTRY}/${USER}/doom-web-frontend:${VERSION}"]
  platforms = ["linux/amd64", "linux/arm64"]
  output = ["type=registry"]
}

# 7. Backend (hipotético)
target "doom-web-backend" {
  inherits = ["_base"]
  dockerfile = "backend/Dockerfile"
  context = "backend"
  tags = ["${REGISTRY}/${USER}/doom-web-backend:${VERSION}"]
  platforms = ["linux/amd64", "linux/arm64"]
  output = ["type=registry"]
}
```

### 🚀 Comandos útiles con docker-bake.hcl

```bash
# ============================================
# LISTAR TARGETS DISPONIBLES
# ============================================
docker buildx bake --print

# ============================================
# DESARROLLO LOCAL
# ============================================

# Build local de desarrollo
docker buildx bake doom-web-dev

# Build local de producción
docker buildx bake doom-web-prod

# Ejecutar el dev después de buildear
docker buildx bake doom-web-dev
docker run -p 3000:3000 doom-web:dev

# ============================================
# VALIDACIÓN Y CHECKS
# ============================================

# Build con validación
docker buildx bake doom-web-validated

# Solo ejecutar checks
docker build --check -f Dockerfile.checked .

# ============================================
# PRODUCTION & MULTI-ARCH
# ============================================

# Build para múltiples arquitecturas (con push)
docker buildx bake doom-web-prod-multiarch

# Build optimizado
docker buildx bake doom-web-optimized

# ============================================
# GRUPOS COMPLETOS
# ============================================

# Ejecutar grupo default (prod)
docker buildx bake

# Ejecutar grupo de desarrollo
docker buildx bake dev

# Ejecutar grupo de CI/CD
docker buildx bake ci

# Ejecutar TODO
docker buildx bake all

# ============================================
# CON VARIABLES PERSONALIZADAS
# ============================================

# Cambiar versión
docker buildx bake --set "VERSION=v2.0.0" doom-web-prod-multiarch

# Cambiar usuario
docker buildx bake --set "USER=otro-usuario" doom-web-prod-multiarch

# Cambiar versión de Node
docker buildx bake --set "NODE_VERSION=22" doom-web-dev

# Combinar variables
docker buildx bake --set "VERSION=v2.0.0" --set "NODE_VERSION=22" all

# ============================================
# DEBUGGING & INFORMATION
# ============================================

# Ver configuración final antes de ejecutar
docker buildx bake --print doom-web-prod

# Ver todos los targets disponibles
docker buildx bake --help

# Build en modo verbose
docker buildx build --progress=plain -f docker-bake.hcl
```

### 🎛️ Formatos soportados en Docker Bake

#### 1. HCL (Recomendado)

```hcl
# docker-bake.hcl
target "app" {
  context = "."
  dockerfile = "Dockerfile"
  tags = ["app:latest"]
}
```

#### 2. JSON

```json
{
  "target": {
    "app": {
      "context": ".",
      "dockerfile": "Dockerfile",
      "tags": ["app:latest"]
    }
  }
}
```

Usar: `docker buildx bake -f bake.json`

#### 3. Compose YAML

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        - NODE_ENV=production
      labels:
        - "com.example.version=1.0.0"
    image: app:latest
```

Usar: `docker buildx bake -f docker-compose.yml`

### 💎 Características avanzadas

#### Variables de entorno

```hcl
variable "BUILDKIT_PROGRESS" {
  default = "plain"  # auto, plain, tty
}

variable "DOCKER_CONTENT_TRUST" {
  default = "1"  # Habilita firma de imágenes
}
```

#### Condiciones y lógica

```hcl
variable "PUSH" {
  default = false
}

target "app" {
  context = "."
  output = PUSH ? ["type=registry"] : ["type=docker"]
}
```

#### Cachés distribuidos

```hcl
target "app" {
  cache-from = [
    "type=registry,ref=myregistry.com/app:buildcache",
    "type=local,src=.docker-cache"
  ]
  cache-to = [
    "type=registry,ref=myregistry.com/app:buildcache,mode=max"
  ]
}
```

#### Secretos en Bake

```hcl
target "app" {
  secret = ["github_token=~/.ssh/id_rsa"]
  
  dockerfile-inline = <<EOT
FROM alpine
RUN --mount=type=secret,id=github_token \
    cat /run/secrets/github_token > /tmp/token
EOT
}
```

### 📊 Integración con CI/CD

#### GitHub Actions con Bake

```yaml
name: Build with Bake
on: [push]

jobs:
  bake:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/bake-action@v4
        with:
          files: ./docker-bake.hcl
          targets: doom-web-prod-multiarch
          push: true
```

#### GitLab CI con Bake

```yaml
docker-build:
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker buildx bake -f docker-bake.hcl all
```

### 🎯 Mejores prácticas

1. **📋 Usa variables**: Evita hardcodear valores
   ```hcl
   variable "VERSION" {
     default = "latest"
   }
   ```

2. **🏷️ Herencia con `inherits`**: Reutiliza configuración común
   ```hcl
   target "_base" {
     labels = {"app" = "doom-web"}
   }
   target "prod" {
     inherits = ["_base"]
   }
   ```

3. **📦 Agrupa targets relacionados**: Facilita mantenimiento
   ```hcl
   group "release" {
     targets = ["app-prod", "frontend", "backend"]
   }
   ```

4. **🔄 Usa `--progress`**: Para mejor debugging
   ```bash
   docker buildx bake --progress=plain app
   ```

5. **💾 Caché persistente**: Para builds más rápidos
   ```hcl
   cache-to = ["type=local,dest=/tmp/buildcache"]
   cache-from = ["type=local,src=/tmp/buildcache"]
   ```

---

## � Resumen de lo aprendido que te permite validar tu configuración de build y realizar una serie de verificaciones antes de ejecutar tu build. Es como un **linter avanzado** para tu Dockerfile y opciones de build, o un modo de **dry-run** para builds. 🎯

### 🌟 ¿Por qué usar Build Checks?

- **✅ Validación temprana**: Detecta problemas antes de ejecutar el build
- **📋 Mejores prácticas**: Asegura que tu Dockerfile sigue las recomendaciones actuales
- **🚫 Anti-patrones**: Identifica patrones problemáticos en tu configuración
- **🔒 Seguridad**: Ayuda a detectar configuraciones inseguras
- **⚡ Eficiencia**: Ahorra tiempo evitando builds fallidos

### 🛠️ Requisitos

- **Buildx**: versión 0.15.0 o posterior
- **docker/build-push-action**: versión 6.6.0 o posterior
- **docker/bake-action**: versión 5.6.0 o posterior

### 🚀 Uso básico

Por defecto, los checks se ejecutan automáticamente cuando haces un build:

```bash
docker build .
```

**Salida de ejemplo:**
```
[+] Building 3.5s (11/11) FINISHED
...

1 warning found (use --debug to expand):
  - JSONArgsRecommended: JSON arguments recommended for CMD to prevent unintended behavior related to OS signals (line 7)
```

### 🔍 Verificar sin construir

Para ejecutar solo los checks sin construir la imagen:

```bash
docker build --check .
```

**Ejemplo de salida detallada:**
```
[+] Building 1.5s (5/5) FINISHED
=> [internal] connecting to local controller
=> [internal] load build definition from Dockerfile
=> => transferring dockerfile: 253B

JSONArgsRecommended - https://docs.docker.com/go/dockerfile/rule/json-args-recommended/
JSON arguments recommended for ENTRYPOINT/CMD to prevent unintended behavior related to OS signals
Dockerfile:7
--------------------
5 |
6 |     COPY index.js .
7 | >>> CMD node index.js
8 |
--------------------
```

### 📝 Ejemplo práctico con nuestro proyecto doom-web

Vamos a probar los checks con nuestro Dockerfile actual:

```bash
cd doom-web
docker build --check .
```

Si hay warnings, puedes ver más detalles con:

```bash
docker --debug build --check .
```

### ⚙️ Configuración avanzada

#### 🚨 Fallar el build en violaciones

Puedes configurar que el build falle cuando se encuentren violaciones usando la directiva `check=error=true`:

```dockerfile
# syntax=docker/dockerfile:1
# check=error=true

FROM node:20-alpine
COPY package*.json ./
RUN npm install
COPY . .
CMD npm start  # Esto generará un warning que ahora será un error
```

También puedes configurarlo vía CLI:

```bash
docker build --build-arg "BUILDKIT_DOCKERFILE_CHECK=error=true" .
```

#### 🙈 Omitir checks específicos

Para saltar checks específicos:

```dockerfile
# syntax=docker/dockerfile:1
# check=skip=JSONArgsRecommended,StageNameCasing

FROM alpine AS BASE_STAGE
CMD echo "Hello, world!"
```

O vía CLI:

```bash
docker build --build-arg "BUILDKIT_DOCKERFILE_CHECK=skip=JSONArgsRecommended" .
```

Para saltar todos los checks:

```dockerfile
# syntax=docker/dockerfile:1
# check=skip=all
```

#### 🧪 Checks experimentales

Para habilitar checks experimentales:

```bash
docker build --build-arg "BUILDKIT_DOCKERFILE_CHECK=experimental=all" .
```

O en el Dockerfile:

```dockerfile
# syntax=docker/dockerfile:1
# check=experimental=all
```

#### 🔧 Combinando parámetros

Puedes combinar múltiples configuraciones separándolas con punto y coma:

```dockerfile
# syntax=docker/dockerfile:1
# check=skip=JSONArgsRecommended;error=true;experimental=all
```

### 🎮 Aplicando checks a nuestro proyecto doom-web

Crear un `Dockerfile.checked` que siga las mejores prácticas:

```dockerfile
# syntax=docker/dockerfile:1
# check=error=true

FROM node:20-alpine AS base

LABEL maintainer="Gisela Torres <gisela.torres@returngis.net>"

WORKDIR /usr/src/app

# Mejores prácticas para el manejo de dependencias
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copiar archivos de la aplicación
COPY . .

# Exponer puerto
EXPOSE 3000

# Usar user no-root por seguridad
RUN chown -R node:node /usr/src/app
USER node

# Usar formato JSON para CMD (evita warnings)
CMD ["npm", "start"]
```

Probar los checks:

```bash
docker build --check -f Dockerfile.checked .
```

### 🎯 Integración con Docker Bake

También puedes usar checks con Docker Bake añadiendo la configuración en tu `docker-bake.hcl`:

```hcl
target "doom-web-checked" {
  context = "."
  dockerfile = "Dockerfile.checked"
  tags = ["doom-web:checked"]
  args = {
    BUILDKIT_DOCKERFILE_CHECK = "error=true"
  }
}

target "doom-web-dry-run" {
  context = "."
  dockerfile = "Dockerfile"
  args = {
    BUILDKIT_DOCKERFILE_CHECK = "error=true;experimental=all"
  }
  call = "check"  # Solo ejecutar checks, no build
}
```

Ejecutar:

```bash
# Solo checks
docker buildx bake doom-web-dry-run --check

# Build con checks estrictos
docker buildx bake doom-web-checked
```

### 🔧 Checks más comunes

| Check | Descripción | Ejemplo problemático |
|-------|-------------|---------------------|
| **JSONArgsRecommended** | CMD/ENTRYPOINT deberían usar formato JSON | `CMD npm start` ❌ |
| **StageNameCasing** | Nombres de stage deberían estar en minúsculas | `FROM alpine AS BASE_STAGE` ❌ |
| **FromAsCasing** | La palabra AS debería estar en mayúsculas | `FROM alpine as base` ❌ |
| **NoEmptyCommand** | Comandos no deberían estar vacíos | `RUN` ❌ |
| **UndefinedVariable** | Variables no definidas en ARG | `RUN echo $UNDEFINED_VAR` ❌ |

### 📊 Integración con CI/CD

#### GitHub Actions

```yaml
name: Docker Build with Checks
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Build with checks
        uses: docker/build-push-action@v6.6.0
        with:
          context: .
          push: false
          build-args: |
            BUILDKIT_DOCKERFILE_CHECK=error=true
```

Los checks aparecerán como anotaciones en las pull requests de GitHub! 📝

### 💡 Mejores prácticas

1. **🎯 Usa checks desde el inicio**: Integra checks en tu workflow de desarrollo
2. **⚠️ Trata warnings como errores**: Usa `check=error=true` en producción
3. **📋 Documenta excepciones**: Si skips checks, documenta por qué
4. **🔄 Actualiza regularmente**: Los checks evolucionan con las mejores prácticas
5. **👥 Estandariza en equipo**: Usa la misma configuración en todo el proyecto

### 🎯 Ejercicio práctico

1. Ejecuta checks en nuestro Dockerfile actual:
   ```bash
   cd doom-web
   docker build --check .
   ```

2. Corrige los warnings encontrados creando un `Dockerfile.best-practices`

3. Añade la configuración a tu `docker-bake.hcl`:
   ```hcl
   target "doom-web-validated" {
     context = "."
     dockerfile = "Dockerfile.best-practices"
     tags = ["doom-web:validated"]
     args = {
       BUILDKIT_DOCKERFILE_CHECK = "error=true"
     }
   }
   ```

4. Prueba el build con checks estrictos:
   ```bash
   docker buildx bake doom-web-validated
   ```

> [!TIP]
> 💡 **Consejo**: Instala la [extensión de Docker para VS Code](https://marketplace.visualstudio.com/items?itemName=docker.docker) para obtener linting en tiempo real de tu Dockerfile.

---

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

5. **� Docker Build Checks**: Validación y linting avanzado
   - Detección temprana de problemas en Dockerfiles
   - Verificación de mejores prácticas de seguridad
   - Integración con CI/CD para calidad de código

6. **�📦 Publicación en Docker Hub**: Distribución de imágenes
   - Nomenclatura correcta de imágenes
   - Autenticación y push de imágenes
   - Gestión de tags y versiones

6. **🔍 Docker Build Checks**: Validación de configuración de builds
   - Detección temprana de problemas
   - Asegura el cumplimiento de mejores prácticas
   - Identificación de configuraciones inseguras

### 🛠️ Herramientas exploradas:

- **Docker CLI**: Comandos básicos de construcción
- **VS Code Extension**: Generación automática de Dockerfiles
- **IA Tools**: Microsoft Edge Copilot y GitHub Copilot
- **Docker Buildx**: Funcionalidades avanzadas con Bake
- **Docker Build Checks**: Validación y linting de Dockerfiles
- **Docker Build Checks**: Validación y verificación de Dockerfiles

### ✨ Beneficios obtenidos:

- ⚡ **Eficiencia**: Builds más rápidos y optimizados
- 🔒 **Seguridad**: Imágenes mínimas con menos superficie de ataque
- 👥 **Colaboración**: Configuraciones compartidas y consistentes
- 🌐 **Portabilidad**: Aplicaciones que funcionan en cualquier entorno
- 📈 **Escalabilidad**: Base sólida para orquestación y microservicios

### 🎯 Próximos pasos recomendados:

1. Experimentar con diferentes estrategias de multi-stage
2. Implementar Docker Bake en proyectos reales
3. Integrar Docker Build Checks en el workflow de desarrollo
4. Explorar Docker Compose para aplicaciones multi-contenedor
5. Aprender sobre orquestación con Kubernetes
6. Profundizar en seguridad de contenedores

> [!SUCCESS]
> 🎉 **¡Felicitaciones!** Ya dominas los fundamentos de la contenerización. Estás listo para el siguiente nivel: orquestación de contenedores.