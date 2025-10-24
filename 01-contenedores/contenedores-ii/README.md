# 📦 Día 2: Trabajando con imágenes Docker

![Docker](imagenes/Trabajando%20con%20imagenes%20de%20Docker.jpeg)

¡Hola lemoncoder 👋🏻! En esta sesión aprenderemos a dominar las imágenes Docker, desde su gestión básica hasta una introducción a la creación de imágenes personalizadas con Dockerfile. Veremos algunas imágenes interesantes que nos demuestren lo fácil que es usar contenedores para todo, así como crear nuestras primeras imágenes básicas con unas pocas instrucciones.

## 🎬 Vídeos de la introducción en el campus

Se asume que has visto los siguientes vídeos para comenzar con este módulo:

| # | Tema | Contenido Clave |
|---|------|-----------------|
| 1 | 📘 Teoría | Conceptos fundamentales de imágenes, capas, pulling, registros y nomenclatura |
| 2 | 🛠️ Demo: Analizar una imagen desde Docker Desktop | Inspeccionar imágenes, ver capas, explorar la estructura interna |
| 3 | 🏷️ Demo: Etiquetas y digest | Entender tags, versiones y digests SHA256 |
| 4 | 🌐 Demo: Un vistazo por la web de Docker Hub | Navegar por Docker Hub, buscar imágenes, entender documentación |
| 5 | 🧪 Demo: Mi primera imagen de Docker | Crear una imagen personalizada con Dockerfile básico |

## 📋 Conceptos de Día 1 que usaremos hoy

Antes de avanzar, recuerda que en la clase anterior aprendimos parámetros importantes que seguiremos usando:

- **`--name`**: Asignar un nombre personalizado al contenedor
- **`-d` o `--detach`**: Ejecutar contenedor en background (sin bloquear el terminal)
- **`-it`**: Modo interactivo con terminal 
- **`--restart`**: Políticas de reinicio del contenedor
- **`docker ps`**: Listar contenedores en ejecución
- **`docker ps -a`**: Listar todos los contenedores (incluidos los detenidos)
- **`docker start <nombre_contenedor>`**: Iniciar un contenedor detenido
- **`docker stop <nombre_contenedor>`**: Detener un contenedor en ejecución
- **`docker rm <nombre_contenedor>`**: Eliminar un contenedor detenido


Si necesitas refrescar estos conceptos, vuelve al [README de Día 1](../contenedores-i/README.md).

---

## 📥 Crear un contenedor a partir de una imagen de Docker

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
También es muy importante, como ya te conté durante la teoría, que las imágenes que elijas sean lo más pequeñas posibles, ya que cuanto más pequeñas sean más rápido se descargarán y más rápido se ejecutarán los contenedores.

También vimos que es muy importante elegir imágenes oficiales o de confianza, ya que estas suelen estar mejor mantenidas y actualizadas.


## 📂 Comprobar las imagenes que ya tenemos en local

Para poder ver las imágenes que tenemos en local podemos usar el siguiente comando:

```bash
docker images
```

o bien

```bash
docker image ls
```

Si se diera el caso de que tenemos muchísimas imágenes también podemos filtrar por nombre del repositorio:

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

Piensa que estas imágenes cuando se descargan se hacen de una forma incremental, es decir, si dos imágenes comparten capas estas solo se descargarán una vez. Por ejemplo, si tienes la imagen de `nginx` y la de `nginx:alpine` la segunda solo descargará las capas que no tenga ya descargadas de la primera. También puede diferir el tamaño que ocupa la imagen dependiendo de la arquitectura para la que esté construida (amd64, arm64, etc.), ya que en realidad son imágenes diferentes.

## 📥 Pulling o descargar una imagen

Hasta ahora, siempre que hemos descargado una imagen ha sido de forma implícita al ejecutar un contenedor con `docker run`, pero también es posible descargar una imagen sin necesidad de ejecutar un contenedor a partir de ella, y esto se hace con el comando `docker pull`.

```bash
docker pull mysql
```

**¿Por qué querría hacer esto?** Esto es útil cuando queremos descargar una imagen para tenerla en local y usarla más adelante y que el proceso de creación del contenedor sea mucho más rápido. Yo he hecho esto incluso cuando he estado de viaje y he tenido una conexión lenta a internet (o cero internet), para tener las imágenes ya descargadas y no tener que esperar a que se descarguen cuando las necesito.

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

### ✅ Mejores prácticas al descargar imágenes

| Práctica | Razón | Ejemplo |
|----------|-------|---------|
| **Usa versiones específicas** | Evita cambios inesperados | `mysql:8.0.35` en lugar de `mysql:latest` |
| **Evita usar `latest`** | Tag `latest` puede cambiar sin aviso | Especifica versión de lanzamiento (`8.0`, `v2.1.0`) |
| **Verifica el digest** | Garantiza que descargaste exactamente lo que esperas | `docker images --digests` |
| **Usa imágenes oficiales** | Mejor mantenimiento y seguridad | `nginx` en lugar de `some-user/nginx` |
| **Revisa la documentación** | Entiende variables de entorno y configuración necesaria | Lee el README en Docker Hub |
| **Descarga cuando tengas conexión lenta** | Evita interrupciones durante creación de contenedores | Usa `docker pull` con anticipación |


Si por algún motivo necesitas descargar todas las versiones de una imagen puedes hacerlo de la siguiente manera:

```bash
docker pull -a wordpress
```

Si bien es cierto que antes funcionaba este comando sin problemas ahora mismo debido a este mensaje: `[DEPRECATION NOTICE] Docker Image Format v1 and Docker Image manifest version 2, schema 1 support is disabled by default and will be removed in an upcoming release. Suggest the author of docker.io/library/wordpress:3 to upgrade the image to the OCI Format or Docker Image manifest v2, schema 2. More information at https://docs.docker.com/go/deprecated-image-specs/` no se puede hacer. Este mensaje significa que la imagen que estás intentando descargar no es compatible con la versión actual de Docker.


## Las imágenes son multi-arquitectura

Docker hace tan bien su trabajo que probablemente no te hayas dado cuenta de que una imagen no es realmente una sola imagen sino varias ¿A qué me refiero con esto? pues a que cuando creamos o alguien crea una imagen tiene que crear tantas imagenes como arquitecturas quiera soportar (amd64, arm64, etc.) y luego Docker las agrupa todas bajo un mismo nombre de imagen. A esto se le llama imágenes multi-arquitectura. No suele ocurrir a menudo con las más usadas pero en ciertas ocasiones te puedes encontrar con que una imagen que querías utilizar no está disponible para tu ordenador.

¿Y cómo puedo saber qué arquitectura tengo?

Dependiendo de tu sistema operativo puedes usar:

```bash
uname -m
```

o también:

```
arch
```

y si estás en Windows puedes usar lo siguiente:

```powershell
Get-CimInstance Win32_OperatingSystem | Select-Object OSArchitecture
```

Lo normal es que ni compruebes esto ni que compruebes si la imagen está disponible para tu arquitectura o no lo está pero si quieres saber para qué arquitecturas está generada cierta imagen puedes hacerlo usando este comando:


```bash
docker manifest inspect NOMBRE_DE_LA_IMAGEN:TAG
```

## 🌍 Variables de entorno para las imágenes

Ya comentamos en la clase anterior que es posible utilizar variables de entorno para configurar los contenedores que ejecutamos a partir de una imagen. Esto es muy útil, ya que muchas imágenes utilizan variables de entorno para configurar aspectos importantes como usuarios, contraseñas, puertos, etc.

También puedes pasar un archivo con múltiples variables usando `--env-file`:

```bash
docker run --name pihole -d \
  --env-file 01-contenedores/contenedores-ii/pihole.env \
  -p 9091:80 \
  pihole/pihole:latest
```


Si tienes muchas variables de entorno, usar un archivo `.env` es más limpio y manejable que pasarlas todas en la línea de comandos.

Y con esto tendrás Pi-hole corriendo en `http://localhost:9091` con las variables de entorno definidas en el archivo `pihole.env`.

>[!INFORMATION]
>Pihole es una herramienta fantástica para bloquear anuncios y rastreadores a nivel de red. Puedes configurarlo como tu servidor DNS y disfrutar de una navegación más limpia y rápida en todos tus dispositivos conectados a la red.


## 🌟 Algunas imágenes interesantes


Ahora vamos a ver algunas imágenes interesantes que te van a permitir practicar todo lo que has aprendido hasta ahora. Las de [LinuxServer](https://www.linuxserver.io/) son muy interesantes, ya que tienen imágenes de aplicaciones muy conocidas como Plex, Nextcloud, etc. **Ahora que conoces los conceptos fundamentales, fíjate cómo se aplican en estos ejemplos:**

Un servidor de **🎬 Radarr** (gestor de películas):

```bash
docker run \
--name=radarr \
-e TZ=Europe/Madrid `# Zona horaria - ¡ya sabes para qué sirve!` \
-p 7878:7878 `# Puerto expuesto para la interfaz web` \
linuxserver/radarr:5.11.0
```

**📺 Plex** (servidor de medios):

```bash
docker run \
--name plex \
-p 32400:32400 \
-d \
linuxserver/plex
```

🎨 Blender (software de modelado 3D)

```bash
docker run -d \
--name=blender \
-e PUID=1000 -e PGID=1000 -e TZ=Etc/UTC `# Variables típicas de LinuxServer` \
-p 3000:3000 -p 3001:3001 \
lscr.io/linuxserver/blender:latest
```

⚡ Speedtest Tracker (para hacer tests de velocidad)

```bash
docker run -d --name speedtest-tracker \
 -p 9090:80 -p 8443:443 \
-e PUID=1000 -e PGID=1000 `# Variables de permisos` \
-e APP_KEY=base64:nyXzCn22VeDmKSdUqul5IOFUFCFv3UoZ02FQm0y+8uk= `# Config específica` \
-e DB_CONNECTION=sqlite `# Configuración de base de datos` \
lscr.io/linuxserver/speedtest-tracker:latest
```

📁 Filezilla (cliente FTP)

```bash
docker run -d \
  --name=filezilla \
  -e PUID=1000 -e PGID=1000 -e TZ=Etc/UTC \
  -p 3000:3000 -p 3001:3001 \
  --restart unless-stopped \
  lscr.io/linuxserver/filezilla:latest
```

👶 BabbyBuddy (para llevar un seguimiento de la alimentación de tu bebé)

```bash
# admin/admin (credenciales por defecto)

docker run -d \
  --name=babybuddy \
  -e PUID=1000 -e PGID=1000 -e TZ=Etc/UTC \
  -e CSRF_TRUSTED_ORIGINS=http://127.0.0.1:8000,https://babybuddy.domain.com `# Variable específica de seguridad` \
  -p 8000:8000 \
  lscr.io/linuxserver/babybuddy:latest
```

**📄 LibreOffice** (suite ofimática)

```bash
docker run -d \
  --name=libreoffice \
  -e PUID=1000 -e PGID=1000 -e TZ=Etc/UTC \
  -p 3000:3000 -p 3002:3001 \
  lscr.io/linuxserver/libreoffice:latest

docker rm -f libreoffice  # Para limpiar después de probar
```

**🦊 Firefox** (navegador web)

```bash
docker run -d \
  --name=firefox \
  -e PUID=1000 -e PGID=1000 -e TZ=Etc/UTC \
  -e FIREFOX_CLI=https://www.lemoncode.net/ \
  -p 3000:3000 -p 3001:3001 \
  --shm-size="1gb" \
  lscr.io/linuxserver/firefox:latest
```

**🏠 Home Assistant** (plataforma de domótica open source)

```bash
docker run -d \
  --name homeassistant \
  --restart=unless-stopped `# Reinicio automático inteligente` \
  -e TZ=Europe/Madrid `# Zona horaria importante para automatizaciones` \
  -p 8123:8123 \
  ghcr.io/home-assistant/home-assistant:stable
```

> 💡 **Tip**: Home Assistant es perfecto para automatizar tu hogar. Tras el primer arranque, accede a `http://localhost:8123` para completar la configuración inicial. ¡Puedes integrar desde luces inteligentes hasta sensores de temperatura!

**🔄 n8n** (plataforma de automatización y orquestación de workflows)

```bash
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -e GENERIC_TIMEZONE="Europe/Madrid" \
  -e TZ="Europe/Madrid" \
  -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
  docker.n8n.io/n8nio/n8n
```

### 📌 ¿Qué puerto tengo que abrir?

¿Y cómo sé qué puertos tengo que abrir? Pues en la documentación de cada imagen te lo indican. Por ejemplo, en la de [Radarr](https://hub.docker.com/r/linuxserver/radarr) te indican que tienes que abrir el puerto 7878.
Por otro lado, puedes saber qué puerto puedes exponer para una imagen que ya tienes descargada con el siguiente comando:

```bash
docker inspect nginx
```

O bien:

```bash
docker inspect --format='{{.Config.ExposedPorts}}' nginx
```

[Aquí](https://fleet.linuxserver.io/) puedes ver todas las que tienen.


## 🔍 Buscar imágenes en Docker Hub

En los vídeos de la introducción pudiste ver cómo podemos buscar imágenes en Docker Hub a través de su web, pero también podemos hacerlo a través del CLI de Docker:


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

## 🏷️ Tags y digests

Por otro lado, si quieres ver los tags de una imagen en Docker Hub puedes hacerlo de la siguiente manera (necesitarás instalar [JQ](https://stedolan.github.io/jq/)):

```bash
curl -s -S 'https://registry.hub.docker.com/v2/repositories/library/nginx/tags/' | jq '."results"[]["name"]' | sort
```


## 🌐 Otros registros diferentes a Docker Hub

Hasta ahora hemos estado trabajando con Docker Hub, pero hay otros registros de imágenes como Artifact Registry de Google, el cual ha sustituido a Google Container Registry, Azure Container Registry, Amazon Elastic Container Registry, etc. con los que también puedes trabajar. En general estos son los que se suelen usar en los entornos corporativos.

### 📊 Comparación de registros principales

| Registro | Proveedor | URL/Dominio | Mejor para | Ejemplos |
|----------|-----------|-------------|-----------|----------|
| **Docker Hub** | Docker Inc. | `docker.io` | Aplicaciones públicas, comunidad | nginx, ubuntu, mysql |
| **Google Artifact Registry** | Google Cloud | `gcr.io`, `us-docker.pkg.dev` | Proyectos en GCP | google-samples, cloud-tools |
| **Microsoft Container Registry** | Microsoft | `mcr.microsoft.com` | Soluciones Microsoft | mssql, dotnet, windows |
| **Amazon ECR** | AWS | `*.dkr.ecr.*.amazonaws.com` | Proyectos en AWS | aws-cli, lambda-runtime |
| **Registro privado local** | Tuyo | `localhost:5000` | Desarrollo local, entorno corporativo | tus imágenes personalizadas |


### 🔍 Google Container Registry > Artifact Registry

Para que veas cómo funciona, vamos a descargar una imagen de Artifact Registry de Google.

```bash
docker run  -p 8080:8080 gcr.io/google-samples/hello-app:1.0
```

### 🏢 Microsoft Artifact Registry

```bash
docker run mcr.microsoft.com/mcr/hello-world
```

## 📋 Introducción a Dockerfile: Construyendo tu primera imagen

Después de haber visto varias imágenes de otros, quizás ya te pique el gusanillo de saber cómo crear las tuyas propias. La forma recomendada de crear imágenes Docker es utilizando un archivo llamado `Dockerfile`, el cual contiene una serie de instrucciones que Docker interpreta para construir la imagen paso a paso.

### 🎯 **¿Por qué Dockerfile es mejor que docker commit?**

- **Reproducible**: Cualquiera puede recrear exactamente la misma imagen
- **Versionable**: Se puede guardar en Git junto con tu código
- **Transparente**: Se ve exactamente qué contiene la imagen
- **Automatizable**: Se puede integrar en pipelines CI/CD

### 🚀 **Ejemplo práctico: Dockerizando nuestro contenido web**

Vamos a crear una imagen personalizada usando el contenido del directorio `web`, el cuál contiene un simple sitio web estático. Usaremos `nginx` como servidor web base.

**Paso 1**: Crear un archivo llamado `Dockerfile` en el directorio `01-contenedores/contenedores-ii/`:

```dockerfile
# Usa la imagen oficial de nginx como base
FROM nginx:latest

# Copia nuestro contenido web personalizado
COPY web/ /usr/share/nginx/html/

# Expone el puerto 80
EXPOSE 80

# nginx se ejecuta automáticamente al iniciar el contenedor
```

Vale, y ahora que tenemos el Dockerfile, ¿cómo construimos la imagen?

**Paso 2**: Construir la imagen desde el directorio que contiene el Dockerfile:

Para construir la imagen necesitamos usar el comando `docker build`y la forma más sencilla (con menos parámetros) de hacerlo es posicionandonos en el mismo directorio donde está el Dockerfile: 

```bash
cd 01-contenedores/contenedores-ii/
```
y ejecutamos:

```bash 

docker build -t mi-nginx-personalizado:v1 .
```

Y voilà! Después de unos segundos tendrás tu imagen personalizada creada. Para comprobar que la tienes puedes hacer:

```bash
docker images
```

y ahí estará `mi-nginx-personalizado` con la etiqueta `v1`.

¿Y cómo ejecuto un contenedor a partir de esta imagen?


**Paso 3**: Ejecutar un contenedor de nuestra imagen personalizada:

Para ejecutarlo es básicamente de la misma forma que ejecutamos cualquier otra imagen que descarguemos de cualquier registro:

```bash
docker run -d --name mi-web -p 8080:80 mi-nginx-personalizado:v1
```

## Demostración de cómo dos imagenes pueden compartir capas

Ahora que ya has creado tu primera imagen de Docker, es importante que sepas que cuanto más "reutilices" instrucciones entre los diferentes Dockerfiles que crees (siempre que sea posible, claro está 🤓), más capas compartirán entre ellas y por lo tanto ocuparán menos espacio en disco y se descargarán más rápido. Para que veas esto en acción te he dejado el ejemplo que mostré durante la clase en el directorio [dos-imagenes-comparten-capas](./dos-imagenes-comparten-capas/) el cuál tiene su propio README.md con las instrucciones para que puedas probarlo tú mismx.

## Bonus ✨

Al finalizar la clase, te mostré brevemente una nueva característica de Docker, la cual nos va a permitir depurar estos Dockerfile de la misma forma que lo hacemos con el código de nuestras aplicaciones. [Puedes leer más información en este artículo](https://www.linkedin.com/posts/docker_debug-docker-builds-with-visual-studio-code-activity-7386119752697466881-OA-0/) o echar un vistazo a este vídeo del canal de return(GiS) (COMING SOON!);

## 🎉 ¡Felicidades!

Ya has llegado al final de este módulo que, junto con los vídeos introductorios y la clase online en directo, te ha permitido conocer los conceptos fundamentales de las imágenes Docker, desde su gestión básica hasta la creación de imágenes personalizadas con Dockerfile.

## Ejercicio sugerido

Si quieres probarte a ti mismo en el arte de crear imágenes Docker, te propongo el siguiente reto:

1. Crea un directorio llamado `mi-aplicacion`.
2. Dentro de este directorio, crea un archivo `index.html` con contenido HTML básico
3. Crea un `Dockerfile` que use `httpd` como base y copie tu `index.html` al lugar correcto para servirlo. Busca la imagen base que sea menos pesada.
4. Construye la imagen con el nombre `mi-aplicacion-web` y etiqueta `v1`.
5. Ejecuta un contenedor a partir de tu imagen y accede a tu aplicación web en el navegador.


### 📚 Próximos pasos

En el **Día 3** profundizaremos en **Dockerfile**, aprendiendo a:

- Sintaxis completa y mejores prácticas
- Multi-stage builds
- Optimización de capas
- Seguridad en la construcción de imágenes
- Integración con CI/CD

Happy coding {🍋}

---
