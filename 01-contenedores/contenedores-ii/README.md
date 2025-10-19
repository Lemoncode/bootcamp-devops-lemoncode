# 📦 Día 2: Trabajando con imágenes Docker

![Docker](imagenes/Trabajando%20con%20imagenes%20de%20Docker.jpeg)

¡Hola lemoncoder 👋🏻! En esta sesión aprenderemos a dominar las imágenes Docker, desde su gestión básica hasta una introducción a la creación de imágenes personalizadas con Dockerfile. Veremos cómo buscar, descargar y crear imágenes, así como optimizar nuestro entorno Docker.

## 🎬 Vídeos de la introducción en el campus

Se asume que has visto los siguientes vídeos para comenzar con este módulo:

| # | Tema |
|---|------|
| 1 | 📘 Teoría |
| 2 | 🛠️ Demo: Analizar una imagen desde Docker Desktop |
| 3 | �️ Demo: Etiquetas y digest |
| 4 | 🌐 Demo: Un vistazo por la web de Docker Hub |
| 5 | 🧪 Demo: Mi primera imagen de Docker |

Te he dejado marcada en la agenda 🍋📺 aquellas secciones que se tratan en los vídeos. Con el resto nos ponemos en la clase online.


### 📚 Contenido
1. [Crear contenedores desde imágenes](#crear-un-contenedor-a-partir-de-una-imagen-de-docker)
2. [Gestión de imágenes locales](#comprobar-las-imagenes-que-ya-tenemos-en-local) 🍋📺
3. [Descarga de imágenes](#pulling-o-descargar-una-imagen) 🍋📺
4. [Conceptos fundamentales](#conceptos-fundamentales-que-necesitas-conocer) 🍋📺
5. [Galería de imágenes útiles](#algunas-imágenes-interesantes)
6. [Registros alternativos](#otros-registros-diferentes-a-docker-hub) 🍋📺
7. [Búsqueda de imágenes](#buscar-imágenes-en-docker-hub)
8. [Creación de imágenes personalizadas](#crear-tu-propia-imagen-a-partir-de-una-imagen-existente) 🍋📺
9. [Inspección y análisis](#inspeccionando-una-imagen)
10. [Limpieza y mantenimiento](#eliminar-una-imagen)
11. [Docker Model Runner: IA y modelos de lenguaje](#docker-model-runner-ia-y-modelos-de-lenguaje-en-contenedores)
12. [Introducción a Dockerfile](#introducción-a-dockerfile-construyendo-tu-primera-imagen) 🍋📺

---

En la primera clase vimos cómo instalar Docker, cómo funcionan los contenedores y cómo crear y ejecutar un contenedor a partir de una imagen. En esta clase vamos a ver cómo trabajar con imágenes, cómo buscarlas, descargarlas, crearlas y subirlas a Docker Hub.

## 🚀 Crear un contenedor a partir de una imagen de docker

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

Esto es útil cuando queremos descargar una imagen para tenerla en local y usarla más adelante y que el proceso de creación del contenedor sea mucho más rápido. Yo he hecho esto incluso cuando he estado de viaje y he tenido una conexión lenta a internet (o cero internet), para tener las imágenes ya descargadas y no tener que esperar a que se descarguen cuando las necesito.

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

## 📦 Descargar todas las versiones/tags de una imagen

Si por algún motivo necesitas descargar todas las versiones de una imagen puedes hacerlo de la siguiente manera:

```bash
docker pull -a wordpress
```

Si bien es cierto que antes funcionaba este comando sin problemas ahora mismo debido a este mensaje: `[DEPRECATION NOTICE] Docker Image Format v1 and Docker Image manifest version 2, schema 1 support is disabled by default and will be removed in an upcoming release. Suggest the author of docker.io/library/wordpress:3 to upgrade the image to the OCI Format or Docker Image manifest v2, schema 2. More information at https://docs.docker.com/go/deprecated-image-specs/` no se puede hacer. Este mensaje significa que la imagen que estás intentando descargar no es compatible con la versión actual de Docker.

## 🔧 Conceptos fundamentales que necesitas conocer

Antes de lanzar contenedores con configuraciones avanzadas, es importante entender los parámetros que veremos en los ejemplos siguientes.

### 🌍 **Variables de entorno (-e)**

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



### 🔒 **Opciones de seguridad (--security-opt)**

Configuran políticas de seguridad del contenedor y controlan qué acceso tiene el contenedor a las llamadas del sistema:

```bash
--security-opt seccomp=unconfined  # Deshabilita el filtro de llamadas del sistema
--security-opt apparmor=unconfined # Deshabilita AppArmor
--security-opt no-new-privileges   # Evita escalada de privilegios
```

**� Valores por defecto (cuando no especificas nada):**

Por defecto, Docker aplica configuraciones **seguras y restrictivas**:

| Opción | Por defecto | Qué significa |
|--------|-------------|---------------|
| **seccomp** | `default` (restrictivo) | Docker aplica un perfil de seccomp que filtra llamadas del sistema peligrosas. Protege contra ataques a nivel de kernel |
| **apparmor** | `docker-default` | Se aplica el perfil de AppArmor específico de Docker que limita operaciones del contenedor |
| **privileges** | No permitidos | Los procesos NO pueden escalar privilegios (cambiar de usuario/grupo) |

**�🔍 Entendiendo cada opción:**

- **`seccomp=unconfined`**: Desactiva el filtro de seguridad de llamadas del sistema (syscalls). Necesario para aplicaciones gráficas como Firefox, Chrome o herramientas de debugging que requieren acceso completo al kernel. **⚠️ Reduce significativamente la seguridad**. Si no lo especificas, Docker mantiene el filtro por defecto (seguro).

- **`apparmor=unconfined`**: Desactiva AppArmor (Mandatory Access Control en Linux). AppArmor proporciona una capa adicional de control de acceso. Al desactivarlo, se permiten más operaciones. Normalmente no es necesario desactivar esto. Si no lo especificas, se aplica el perfil `docker-default` (recomendado).

- **`no-new-privileges`**: Evita que procesos dentro del contenedor puedan escalar privilegios. Es una buena práctica de seguridad para aplicaciones que no necesitan cambiar de usuario/grupo durante la ejecución. Este comportamiento es el **por defecto** en Docker, así que no necesitas especificarlo a menos que uses `--privileged`.

**⚠️ Importante**: `seccomp=unconfined` se usa para apps gráficas que necesitan acceso completo al sistema, pero reduce la seguridad. Solo úsalo cuando sea absolutamente necesario.

**💡 Recomendación**: La configuración por defecto de Docker es segura. Mantén la restricción si tu aplicación no necesita acceso de bajo nivel. Solo desactívalo cuando sea necesario, y siempre como última opción después de otros intentos.

**Ejemplos de uso:**

```bash
# Contenedor seguro (sin especificar nada, usa valores por defecto)
docker run -d --name mi-app mi-app:latest
# ✅ Tiene: seccomp restrictivo + apparmor + no-new-privileges

# Para una aplicación gráfica que necesita acceso completo
docker run -d \
  --security-opt seccomp=unconfined \
  --name firefox \
  lscr.io/linuxserver/firefox:latest
# ⚠️ Menos seguro, pero necesario para apps gráficas

# Para una aplicación de debugging que necesita más permisos
docker run -d \
  --security-opt seccomp=unconfined \
  --security-opt apparmor=unconfined \
  --name debug-app \
  mi-app-debug:latest
# ⚠️ Máximo permiso (usar solo para debugging)

# Para una aplicación que quieres mantener segura (explícitamente)
docker run -d \
  --security-opt no-new-privileges \
  --name secure-app \
  mi-app:latest
# ✅ Especificamos explícitamente que no hay escalada de privilegios
```

**📊 Matriz de seguridad:**

```
Más seguro  ───────────────────────────────── Menos seguro
    ↓                                            ↓
[Por defecto] → [no-new-privileges] → [seccomp=unconfined] → [--privileged]
  (seguro)      (muy seguro)          (arriesgado)           (muy arriesgado)
```

### 🧠 **Memoria compartida (--shm-size)**

Algunos navegadores y apps gráficas necesitan más memoria compartida:

```bash
--shm-size="1gb"    # Asigna 1GB de memoria compartida
--shm-size="512m"   # Asigna 512MB
```

**🎯 Uso típico**: Firefox, Chrome, aplicaciones que renderizan gráficos.

### 🎭 **Privilegios (--privileged)**

Da acceso completo al sistema host al contenedor:

```bash
--privileged  # Acceso completo (usar con precaución)
```

**🚨 Solo usar cuando sea absolutamente necesario** (ej: Home Assistant para acceso a hardware USB).

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
  --security-opt seccomp=unconfined `# ¡Recuerdas esto! Para apps gráficas` \
  -e PUID=1000 -e PGID=1000 -e TZ=Etc/UTC \
  -p 3000:3000 -p 3001:3001 \
  --restart unless-stopped `# Política de reinicio que aprendiste` \
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
  --security-opt seccomp=unconfined `# Para aplicación gráfica` \
  -e PUID=1000 -e PGID=1000 -e TZ=Etc/UTC \
  -p 3000:3000 -p 3002:3001 \
  lscr.io/linuxserver/libreoffice:latest

docker rm -f libreoffice  # Para limpiar después de probar
```

**🦊 Firefox** (navegador web)

```bash
docker run -d \
  --name=firefox \
  --security-opt seccomp=unconfined `# Necesario para el navegador` \
  -e PUID=1000 -e PGID=1000 -e TZ=Etc/UTC \
  -e FIREFOX_CLI=https://www.lemoncode.net/ `# URL inicial personalizada` \
  -p 3000:3000 -p 3001:3001 \
  --shm-size="1gb" `# ¡Memoria compartida para el navegador!` \
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
docker run -it --rm \
 --name n8n \
 -p 5678:5678 \
 -e GENERIC_TIMEZONE="Europe/Madrid" \
 -e TZ="Europe/Madrid" \
 -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
 -e N8N_RUNNERS_ENABLED=true \
 -v n8n_data:/home/node/.n8n \
 docker.n8n.io/n8nio/n8n
```

**Características principales de n8n:**
- 🎯 Automatiza workflows entre aplicaciones
- 🔗 Conecta más de 400 integraciones (APIs, SaaS, etc.)
- 📊 Interfaz visual para crear automatizaciones sin código
- 💾 Persiste datos con volúmenes Docker
- 🚀 Perfecta para DevOps y automatización de procesos

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


## 🌐 Otros registros diferentes a Docker Hub

Hasta ahora hemos estado trabajando con Docker Hub, pero hay otros registros de imágenes como Artifact Registry de Google, el cual ha sustituido a Google Container Registry, Azure Container Registry, Amazon Elastic Container Registry, etc. con los que también puedes trabajar. En general estos son los que se suelen usar en los entornos corporativos.


### 🔍 Google Container Registry > Artifact Registry

Para que veas cómo funciona, vamos a descargar una imagen de Artifact Registry de Google.

```bash
docker run  -p 8080:8080 gcr.io/google-samples/hello-app:1.0
```

### 🏢 Microsoft Artifact Registry

```bash
docker run mcr.microsoft.com/mcr/hello-world
```

## 🗄️ Crear tu propio registro Docker privado en un contenedor

Puedes levantar un registro privado de Docker en tu máquina usando la imagen oficial `registry`. Esto es útil para compartir imágenes en tu equipo o entorno local.

```bash
docker run -d -p 5000:5000 --name registry registry:2
```

Esto inicia un registro accesible en `localhost:5000`.

### 📦 Subir una imagen a tu registro privado

1. Etiqueta la imagen para tu registro local:
  ```bash
  docker tag nginx localhost:5000/nginx
  ```
2. Sube la imagen:
  ```bash
  docker push localhost:5000/nginx
  ```

### ⬇️ Descargar una imagen desde tu registro privado

```bash
docker pull localhost:5000/nginx
```

> 💡 **Tip:** Para entornos de producción, añade autenticación y TLS. Consulta la [documentación oficial](https://docs.docker.com/registry/) para más opciones.

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

## 🏷️ El CLI no te devuelve los tags, pero puedes hacerlo así, instalando JQ (https://stedolan.github.io/jq/)

Por otro lado, si quieres ver los tags de una imagen en Docker Hub puedes hacerlo de la siguiente manera:

```bash
curl -s -S 'https://registry.hub.docker.com/v2/repositories/library/nginx/tags/' | jq '."results"[]["name"]' | sort
```

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

## 🤖 Docker Model Runner: IA y modelos de lenguaje en contenedores

Antes de profundizar en la creación de imágenes con Dockerfile, es importante conocer **Docker Model Runner**, una característica beta que representa el futuro de la IA en el ecosistema Docker. Esta herramienta revoluciona la forma en que trabajamos con modelos de inteligencia artificial y grandes modelos de lenguaje (LLMs).

### 🎯 **¿Qué es Docker Model Runner?**

Docker Model Runner es una herramienta integrada en Docker Desktop y Docker Engine que permite gestionar, ejecutar y desplegar modelos de IA de forma sencilla. Está diseñada específicamente para desarrolladores que quieren integrar capacidades de IA en sus aplicaciones sin complicaciones.

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


```
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

## � ¡Felicidades!

En esta segunda clase has aprendido a:

- 🚀 Crear contenedores desde imágenes Docker de forma eficiente.
- 📂 Gestionar imágenes locales: listar, filtrar y organizar tu colección de imágenes.
- 📥 Descargar imágenes estratégicamente con versiones específicas y digests.
- 🔧 Dominar conceptos fundamentales: variables de entorno, políticas de reinicio y opciones de seguridad.
- 🌟 Explorar una galería completa de imágenes útiles de LinuxServer y otros proveedores.
- 🌐 Trabajar con registros múltiples: Docker Hub, Google Artifact Registry, Microsoft Container Registry.
- 🔍 Realizar búsquedas avanzadas en Docker Hub con filtros y formato personalizado.
- 🛠️ Crear imágenes personalizadas usando `docker commit` y modificando contenedores existentes.
- 🔎 Inspeccionar imágenes en profundidad: analizar capas, configuración y metadata.
- 🗑️ Mantener el sistema optimizado eliminando imágenes no utilizadas.
- 🤖 Conocer Docker Model Runner: la herramienta beta para gestionar modelos de IA y LLMs.
- 🌐 Integrar modelos de IA usando APIs compatibles con OpenAI desde contenedores.
- ⚡ Ejecutar aplicaciones GenAI localmente con Docker Model Runner.
- 📋 Introducción a Dockerfile: fundamentos para construir imágenes de forma reproducible.
- 🎯 Entender las mejores prácticas: por qué Dockerfile es superior a `docker commit`.

En la siguiente clase profundizaremos en Dockerfile y aprenderás a crear imágenes optimizadas para producción.

Happy coding {🍋}

---


<!--
## ⏱️ Distribución temporal (3 horas)

**Primera hora (60 min):**
- 🚀 Repaso y creación de contenedores (15 min)
- 📂 Gestión de imágenes locales (15 min)
- 📥 Descarga de imágenes (15 min)
- 🔧 Conceptos fundamentales - Parte 1: Variables y reinicio (15 min)

**Segunda hora (60 min):**
- 🔧 Conceptos fundamentales - Parte 2: Seguridad y memoria (15 min)
- 🌟 Galería de imágenes útiles - Sesión práctica (45 min)
  - *Esta es la sección más divertida y práctica*

**Tercera hora (60 min):**
- 🌐 Otros registros (10 min)
- 🔍 Búsqueda de imágenes (15 min)
- 🛠️ Crear imagen personalizada (20 min)
- 🔎 Inspección y análisis (10 min)
- 📋 Introducción a Dockerfile (15 min)

**Tiempo de buffer: ~10-15 minutos** para Q&A y troubleshooting
-->