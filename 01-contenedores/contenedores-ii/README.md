# 📦 Día 2: Trabajando con imágenes Docker

![Docker](imagenes/Trabajando%20con%20imagenes%20de%20Docker.jpeg)

¡Hola lemoncoder 👋🏻! En esta sesión aprenderemos a dominar las imágenes Docker, desde su gestión básica hasta una introducción a la creación de imágenes personalizadas con Dockerfile. Veremos cómo buscar, descargar y crear imágenes, así como optimizar nuestro entorno Docker.

## 🎬 Vídeos de la introducción en el campus

Se asume que has visto los siguientes vídeos para comenzar con este módulo:

| # | Tema | Contenido Clave |
|---|------|-----------------|
| 1 | 📘 Teoría | Conceptos fundamentales de imágenes, capas, registros y nomenclatura |
| 2 | 🛠️ Demo: Analizar una imagen desde Docker Desktop | Inspeccionar imágenes, ver capas, explorar la estructura interna |
| 3 | 🏷️ Demo: Etiquetas y digest | Entender tags, versiones y digests SHA256 |
| 4 | 🌐 Demo: Un vistazo por la web de Docker Hub | Navegar por Docker Hub, buscar imágenes, entender documentación |
| 5 | 🧪 Demo: Mi primera imagen de Docker | Crear una imagen personalizada con Dockerfile básico |

Te he dejado marcada en la agenda 🍋📺 aquellas secciones que se tratan en los vídeos. Con el resto nos ponemos en la clase online.

## 🎯 Qué aprenderás en este módulo

En la primera clase vimos cómo instalar Docker, cómo funcionan los contenedores y cómo crear y ejecutar un contenedor a partir de una imagen. **En esta clase vamos a dominar las imágenes**: cómo buscarlas, descargarlas inteligentemente, crearlas personalizadas, y entender el ecosistema completo de Docker.

Este módulo te dará las herramientas para:
- ✅ Gestionar eficientemente el ciclo de vida de imágenes
- ✅ Buscar y elegir las imágenes adecuadas para tus necesidades
- ✅ Crear imágenes personalizadas reproducibles
- ✅ Entender los registros de Docker y cómo funcionan
- ✅ Optimizar tu entorno Docker y mantenerlo limpio
- ✅ Explorar herramientas avanzadas del ecosistema Docker


### 📚 Contenido

1. [📥 Crear un contenedor a partir de una imagen de Docker](#-crear-un-contenedor-a-partir-de-una-imagen-de-docker)
2. [📂 Comprobar las imagenes que ya tenemos en local](#📂-comprobar-las-imagenes-que-ya-tenemos-en-local) 🍋📺
3. [📥 Pulling o descargar una imagen](#📥-pulling-o-descargar-una-imagen) 🍋📺
4. [🌍 Variables de entorno para las imágenes](#🌍-variables-de-entorno-para-las-imagenes) 🍋📺
5. [🌟 Algunas imágenes interesantes](#🌟-algunas-imágenes-interesantes)
6. [🌐 Otros registros diferentes a Docker Hub](#🌐-otros-registros-diferentes-a-docker-hub) 🍋📺
7. [Crear tu propio registro privado](#🔒-crear-tu-propio-registro-docker-privado-en-un-contenedor)
8. [Búsqueda de imágenes](#buscar-imágenes-en-docker-hub)
9. [Tags y digests](#tags-y-digests) 
12. [Limpieza y mantenimiento](#eliminar-una-imagen)
13. [Docker Extensions](#🧩-docker-extensions-extiende-docker-desktop)
14. [Docker Model Runner](#🤖-docker-model-runner-ia-y-modelos-de-lenguaje-en-contenedores)
10. [Creación de imágenes personalizadas](#crear-tu-propia-imagen-a-partir-de-una-imagen-existente) 🍋📺
11. [Inspección y análisis](#inspeccionando-una-imagen)
15. [Introducción a Dockerfile](#📋-introducción-a-dockerfile-construyendo-tu-primera-imagen) 🍋📺

---

## 📋 Conceptos de Día 1 que usaremos hoy

Antes de avanzar, recuerda que en la clase anterior aprendimos parámetros importantes que seguiremos usando:

- **`-d` o `--detach`**: Ejecutar contenedor en background (sin bloquear el terminal)
- **`--rm`**: Eliminar el contenedor automáticamente al parar (útil para pruebas)
- **`-it`**: Modo interactivo con terminal (solo para comandos que lo necesitan)
- **`--restart`**: Políticas de reinicio del contenedor
- **Límites de CPU/Memoria** (`--memory`, `--cpus`): Controlar recursos

Si necesitas refrescar estos conceptos, vuelve a la sección correspondiente en el README de Día 1.

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

## 📂 Comprobar las imagenes que ya tenemos en local

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

## 📥 Pulling o descargar una imagen

Para descargar una imagen no es necesario tener que ejecutar un contenedor, simplemente con el comando `pull` es suficiente.

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
| **Usa imágenes oficiales** | Mejor mantenimiento y seguridad | `library/nginx` en lugar de `some-user/nginx` |
| **Revisa la documentación** | Entiende variables de entorno y configuración necesaria | Lee el README en Docker Hub |
| **Descarga cuando tengas conexión lenta** | Evita interrupciones durante creación de contenedores | Usa `docker pull` con anticipación |



Si por algún motivo necesitas descargar todas las versiones de una imagen puedes hacerlo de la siguiente manera:

```bash
docker pull -a wordpress
```

Si bien es cierto que antes funcionaba este comando sin problemas ahora mismo debido a este mensaje: `[DEPRECATION NOTICE] Docker Image Format v1 and Docker Image manifest version 2, schema 1 support is disabled by default and will be removed in an upcoming release. Suggest the author of docker.io/library/wordpress:3 to upgrade the image to the OCI Format or Docker Image manifest v2, schema 2. More information at https://docs.docker.com/go/deprecated-image-specs/` no se puede hacer. Este mensaje significa que la imagen que estás intentando descargar no es compatible con la versión actual de Docker.


## 🌍 Variables de entorno para las imágenes

Las variables de entorno permiten configurar aplicaciones sin modificar la imagen.

```bash
# Ejemplos de variables típicas
-e PUID=1000          # User ID - para permisos de archivos
-e PGID=1000          # Group ID - para permisos de grupo
-e TZ=Europe/Madrid   # Timezone - zona horaria del contenedor
-e PASSWORD=lemoncode # Configuración específica de la app
```

**🔍 Variables más comunes:**
- `TZ`: Zona horaria (America/New_York, Europe/London, etc.)
- `PUID/PGID`: IDs de usuario/grupo para manejo de permisos. 
- `PASSWORD/USER`: Credenciales de acceso
- `DB_*`: Configuración de base de datos
- `APP_*`: Configuraciones específicas de la aplicación

---

## 🌟 Algunas imágenes interesantes

Las de [LinuxServer](https://www.linuxserver.io/) son muy interesantes, ya que tienen imágenes de aplicaciones muy conocidas como Plex, Nextcloud, etc. **Ahora que conoces los conceptos fundamentales, fíjate cómo se aplican en estos ejemplos:**

Un servidor de **🎬 Radarr** (gestor de películas):

```bash
docker run \
--name=radarr \
-e UMASK_SET=022 `# Variables de entorno para configurar permisos` \
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

**💻 VS Code Server** (Visual Studio Code en un contenedor)

```bash
docker run -d \
--name=code-server \
-e PUID=1000 `# ID de usuario para permisos` \
-e PGID=1000 `# ID de grupo para permisos` \
-e TZ=Etc/UTC `# Zona horaria` \
-e PASSWORD=lemoncode `# Variable para configurar contraseña` \
-p 8443:8443 \
lscr.io/linuxserver/code-server:latest
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

**Características principales de n8n:**
- 🎯 Automatiza workflows entre aplicaciones
- 🔗 Conecta más de 400 integraciones (APIs, SaaS, etc.)
- 📊 Interfaz visual para crear automatizaciones sin código
-  Perfecta para DevOps y automatización de procesos

**Acceso:** Una vez ejecutado, accede a `http://localhost:5678` para completar la configuración inicial.

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

Elimina todos los contenedores:

```bash
docker rm -f $(docker ps -a -q)
```

[Aquí](https://fleet.linuxserver.io/) puedes ver todas las que tienen.


## 🔍 Buscar imágenes en Docker Hub

Ya vimos en el primer día cómo buscar imágenes en Docker Hub, pero vamos a recordarlo.

Podemos hacerlo a través del CLI de Docker:

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

**🔎 Cómo explorar imágenes disponibles en GCR:**
- **Web**: https://console.cloud.google.com/artifacts/browse
- **CLI**: `gcloud container images list` (requiere autenticación)
- **Artifact Hub**: https://artifacthub.io/ (buscador multi-registro)

### 🏢 Microsoft Artifact Registry

```bash
docker run mcr.microsoft.com/mcr/hello-world
```

**🔎 Cómo explorar imágenes disponibles en MCR:**
- **Web**: https://mcr.microsoft.com/
- Puedes navegar por categorías (Windows, Linux, .NET, etc.)
- Cada imagen tiene documentación de uso detallada



### ⬇️ Descargar una imagen desde tu registro privado

```bash
docker pull localhost:5000/nginx
```

> 💡 **Tip:** Para entornos de producción, añade autenticación y TLS. Consulta la [documentación oficial](https://docs.docker.com/registry/) para más opciones.



## 🛠️ Crear tu propia imagen a partir de una imagen existente

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

## 🔎 Inspeccionando una imagen

Para inspeccionar una imagen puedes hacerlo de la siguiente manera:

```bash
docker inspect whale-nginx:v1
```

El apartado llamado `Layers` te indica cuántas capas tiene la imagen. Esto es importante porque cada instrucción en el Dockerfile genera una capa, excepto las que contienen metadata.

## 🔎 Explorando las capas de una imagen

Las imágenes Docker están compuestas por capas, cada una representando un cambio incremental. Puedes ver las capas de una imagen con el siguiente comando:

```bash
docker history whale-nginx:v1
```

A día de hoy puedes hacer en Docker Desktop, simplemente seleccionando la imagen:

![Capas de una imagen en Docker Desktop](imagenes/Capas%20de%20una%20imagen.png)

## 🗑️ Eliminar una imagen

Si intentamos eliminar una imagen y hay algún contenedor que la está utilizando no será posible, dará error, incluso si este ya terminó de ejecutarse.

```bash
docker rmi whale-nginx:v1
```

Si quisiéramos eliminar SOLO las imágenes que no se están utilizando:

```bash
docker image prune -a
```

Este comando elimina todas las imágenes que no tienen contenedores asociados (ni en ejecución ni detenidos). Es muy útil para liberar espacio después de experimentar con muchas imágenes.

**⚠️ Advertencia**: `docker image prune -a` elimina TODAS las imágenes no usadas. Asegúrate de que no necesitas ninguna antes de ejecutarlo.

**Otras opciones de limpieza:**

```bash
# Eliminar imágenes sin etiquetar
docker image prune -f

# Ver cuánto espacio ahorrarías
docker image prune -a --dry-run

# Eliminar imágenes creadas hace más de X horas
docker image prune -a --filter "until=24h"
```

---

## 🧩 Docker Extensions: Extiende Docker Desktop

**Docker Extensions** es un ecosistema de complementos que extienden la funcionalidad de Docker Desktop, permitiéndote agregar herramientas e integraciones adicionales directamente desde la interfaz gráfica. Las extensiones te permiten trabajar de manera más eficiente al integrar herramientas populares sin abandonar Docker Desktop.


### ✨ **¿Qué son Docker Extensions?**

Docker Extensions son aplicaciones pequeñas que se ejecutan como contenedores y añaden funcionalidades a Docker Desktop. Actúan como un puente entre Docker y otras herramientas de desarrollo, permitiendo:

- **Integración con herramientas populares**: Kubernetes, Snyk, Portainer, LazyDocker, etc.
- **Interfaz visual mejorada**: Alternativas a la CLI para tareas comunes
- **Automatización**: Scripts y workflows para tareas repetitivas
- **Monitoreo avanzado**: Análisis de contenedores, imágenes y recursos
- **Seguridad**: Escaneo de vulnerabilidades y análisis de seguridad

### 🚀 **Cómo instalar Docker Extensions**

#### **Paso 1: Acceder a la tienda de extensiones**

1. Abre **Docker Desktop**
2. Haz clic en el icono de **"Extensions"** en la barra lateral (icono de piezas de puzzle)
3. Se abrirá la tienda de extensiones de Docker

#### **Paso 2: Buscar e instalar una extensión**

Por ejemplo, para instalar **Portainer** (gestor visual de contenedores):

1. En la barra de búsqueda, escribe "Portainer"
2. Haz clic en el resultado de Portainer
3. Haz clic en el botón **"Install"**
4. Espera a que se descargue e instale (normalmente tarda unos segundos)

#### **Paso 3: Usar la extensión**

Una vez instalada, aparecerá en la barra lateral de Docker Desktop y podrás acceder a ella haciendo clic.

![Extensiones de Docker Desktop](imagenes/Extensiones%20de%20Docker.png)


### ⚙️ **Crear tus propias extensiones (Avanzado)**

Si eres desarrollador, puedes crear tus propias extensiones usando:
- **React** para la interfaz de usuario
- **Docker SDK** para interactuar con el engine
- **Docker Compose** para empaquetar la extensión

Para más información sobre desarrollo de extensiones, consulta la [documentación oficial de Docker Extensions](https://docs.docker.com/desktop/extensions/dev/).

### 🎓 **Lo que aprendes con Docker Extensions**

- ✅ Cómo extender Docker Desktop con funcionalidad adicional
- ✅ Integración con herramientas de seguridad (Snyk)
- ✅ Gestión visual alternativa a la CLI
- ✅ Automatización de tareas comunes
- ✅ Acceso a funcionalidades avanzadas sin scripting

---

## 🤖 Docker Model Runner: IA y modelos de lenguaje en contenedores

En los últimos tiempos Docker se ha volcado en integrar capacidades de inteligencia artificial directamente en su ecosistema. Por lo que además de poder crear y gestionar contenedores tradicionales, ahora es posible trabajar con modelos de IA y grandes modelos de lenguaje (LLMs) de forma nativa. Para ello ha creado una herramienta llamada **Docker Model Runner**, la cual te permite descargar imágenes que lo que contienen son modelos de IA listos para usar.

### ✨ **Características principales**

- **🔄 Gestión simplificada**: Descarga y sube modelos directamente desde/hacia Docker Hub
- **🌐 APIs compatibles con OpenAI**: Sirve modelos con endpoints familiares para fácil integración
- **📦 Empaquetado OCI**: Convierte archivos GGUF en artefactos OCI y publícalos en cualquier registro
- **💻 Interfaz dual**: Interactúa desde línea de comandos o la GUI de Docker Desktop
- **📊 Gestión local**: Administra modelos locales y visualiza logs de ejecución

### 🚀 **Cómo funciona**

Los modelos se descargan desde Docker Hub la primera vez que se usan y se almacenan localmente. Se cargan en memoria solo cuando se solicita y se descargan cuando no están en uso para optimizar recursos. Después de la descarga inicial, quedan en caché para acceso rápido.

### 🛠️ **Comandos esenciales**

```bash
# Habilitar Docker Model Runner (desde Docker Desktop settings)
# Beta features > Enable Docker Model Runner

# Verificar instalación
docker model version

# Ejecutar un modelo
docker model run ai/gemma3

# Listar modelos locales
docker model ls
```

### 🔗 **Modelos disponibles**

Todos los modelos están disponibles en el [namespace público de Docker Hub](https://hub.docker.com/u/ai).

### 💡 **Casos de uso típicos**

- **Desarrollo de aplicaciones GenAI**: Integra IA en tus apps sin configuración compleja
- **Prototipado rápido**: Prueba diferentes modelos localmente antes del despliegue
- **Pipelines CI/CD**: Incluye capacidades de IA en tus flujos de trabajo automatizados
- **Experimentación ML**: Testa modelos sin depender de servicios externos


### 🔍 **Compatibilidad con herramientas existentes**

Docker Model Runner se integra perfectamente con:
- **Docker Compose**: Incluye modelos en tus stacks multi-contenedor
- **Testcontainers**: Para Java y Go, permite testing con modelos de IA
- **Dockerfile**: Puedes referenciar modelos en tus imágenes personalizadas

> 💡 **¿Por qué es importante?** Docker Model Runner democratiza el acceso a la IA, permitiendo que cualquier desarrollador pueda trabajar con modelos avanzados usando las herramientas Docker que ya conoce. Es especialmente valioso para crear aplicaciones que necesiten procesamiento de lenguaje natural, generación de texto, o análisis semántico.

---

## 📋 Introducción a Dockerfile: Construyendo tu primera imagen

Hasta ahora hemos usado `docker commit` para crear imágenes a partir de contenedores modificados, pero esta no es la mejor práctica en el mundo real. La forma correcta y reproducible de crear imágenes es usando un `Dockerfile`.

### 🎯 **¿Por qué Dockerfile es mejor que docker commit?**

- **Reproducible**: Cualquiera puede recrear exactamente la misma imagen
- **Versionable**: Se puede guardar en Git junto con tu código
- **Transparente**: Se ve exactamente qué contiene la imagen
- **Automatizable**: Se puede integrar en pipelines CI/CD

### 🚀 **Ejemplo práctico: Dockerizando nuestro contenido web**

Vamos a crear una imagen personalizada usando el contenido del directorio `web` que hemos estado usando:

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

**Paso 2**: Construir la imagen desde el directorio que contiene el Dockerfile:

```bash
cd 01-contenedores/contenedores-ii/
docker build -t mi-nginx-personalizado:v1 .
```

**Paso 3**: Ejecutar un contenedor de nuestra imagen personalizada:

```bash
docker run -d --name mi-web -p 8080:80 mi-nginx-personalizado:v1
```

### 🔍 **Comparación: docker commit vs Dockerfile**

| Método | Reproducibilidad | Mantenibilidad | Uso en producción |
|--------|------------------|----------------|-------------------|
| `docker commit` | ❌ Baja | ❌ Difícil | ❌ No recomendado |
| `Dockerfile` | ✅ Alta | ✅ Fácil | ✅ Best practice |

### 🎓 **Lo que aprenderás en el próximo módulo**

- **Sintaxis completa** de Dockerfile
- **Mejores prácticas** para optimizar imágenes
- **Multi-stage builds** para imágenes más pequeñas
- **Gestión de capas** para builds eficientes
- **Variables y argumentos** para imágenes flexibles
- **Seguridad** en la construcción de imágenes

> 💡 **Consejo**: El ejemplo que acabamos de ver es básico. En el próximo módulo aprenderás a crear Dockerfiles mucho más sofisticados y optimizados para aplicaciones reales.

---

## 📚 Comandos Docker más comunes en Día 2

Aquí tienes un resumen rápido de los comandos que has aprendido:

### 🏃 Ver y gestionar imágenes
```bash
docker images                          # Listar imágenes locales
docker image ls                        # Alternativa a docker images
docker images nginx                    # Filtrar por nombre
docker images --digests                # Ver digests (hashes)
```

### 📥 Descargar imágenes
```bash
docker pull mysql                      # Descargar versión latest
docker pull mysql:8.0.35              # Descargar versión específica
docker pull redis@sha256:...          # Descargar por digest
```

### 🔍 Buscar imágenes
```bash
docker search nginx                    # Buscar en Docker Hub
docker search --filter=stars=50 nginx  # Filtrar por estrellas
docker search --filter is-official=true nginx  # Solo oficiales
```

### 🛠️ Crear y gestionar imágenes
```bash
docker commit nombre-contenedor nombre-imagen:tag    # Crear imagen desde contenedor
docker inspect nombre-imagen                        # Inspeccionar imagen
docker history nombre-imagen                        # Ver capas de la imagen
docker rmi nombre-imagen                            # Eliminar imagen
docker image prune -a                               # Limpiar imágenes sin usar
```

### 🌐 Trabajar con registros
```bash
docker pull gcr.io/google-samples/hello-app:1.0     # Descargar de GCR
docker pull mcr.microsoft.com/mssql/server:2019     # Descargar de MCR
docker tag nginx localhost:5000/nginx               # Etiquetar para registro local
docker push localhost:5000/nginx                    # Subir a registro privado
```

---

## 🎉 ¡Felicidades!

En esta segunda clase has aprendido a:

- 🚀 **Crear contenedores desde imágenes**: Usar comandos `docker run` con parámetros avanzados.
- 📂 **Gestión de imágenes**: Listar, filtrar, inspeccionar y organizar tu colección de imágenes locales.
- 📥 **Descargar inteligentemente**: Usar versiones específicas, digests y evitar sorpresas con `latest`.
- 🔧 **Conceptos fundamentales**: Variables de entorno (TZ, PUID, PGID), políticas de reinicio y seguridad.
- 🌟 **Galería de aplicaciones**: Conocer imágenes útiles de LinuxServer, oficial y otros proveedores.
- 🌐 **Registros múltiples**: Trabajar con Docker Hub, Google Artifact Registry, Microsoft Container Registry.
- 🗄️ **Registro privado local**: Crear y gestionar tu propio registro Docker en un contenedor.
- 🔍 **Buscar imágenes**: Navegar Docker Hub con filtros avanzados y formato personalizado.
- 🏷️ **Tags y digests**: Entender la nomenclatura y verificar integridad de imágenes.
- 🛠️ **Crear imágenes personalizadas**: Usar `docker commit` para modificar contenedores existentes.
- 🔎 **Inspeccionar imágenes**: Analizar capas (layers), configuración y metadata en profundidad.
- 🗑️ **Optimizar espacio**: Eliminar imágenes no utilizadas y mantener tu entorno limpio.
- 🧩 **Docker Extensions**: Extender funcionalidades de Docker Desktop con complementos.
- 🤖 **Docker Model Runner**: Gestionar modelos de IA y LLMs directamente desde Docker (ya disponible en producción).
- 📋 **Introducción a Dockerfile**: Fundamentos para crear imágenes de forma reproducible y profesional.

### 🎯 Lo más importante

**La progresión es clara:** Hemos pasado de simplemente _ejecutar_ contenedores (Día 1) a _dominar_ las imágenes, sus fuentes, cómo crearlas y cómo optimizar nuestro flujo de trabajo. Ahora tienes las herramientas para trabajar profesionalmente con Docker.

### 📚 Próximos pasos

En el **Día 3** profundizaremos en **Dockerfile**, aprendiendo a:
- Sintaxis completa y mejores prácticas
- Multi-stage builds
- Optimización de capas
- Seguridad en la construcción de imágenes
- Integración con CI/CD

Happy coding {🍋}

---
