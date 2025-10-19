# 📦 Día 4: Almacenamiento en Docker

![Docker](imagenes/Cómo%20gestionar%20el%20almacenamiento%20en%20Docker.jpeg)

## 📋 Agenda

- [🔗 Bind mounts](#-bind-mounts)
  - [Crear bind mount con --mount](#crear-bind-mount-con---mount)
  - [Crear bind mount con -v](#crear-bind-mount-con--v)
  - [Bind mount read-only](#usar-el-bind-mount-como-read-only)
- [💾 Volúmenes](#-volúmenes)
  - [Crear un volumen](#crear-un-volumen)
  - [Usar volumen en contenedor](#usar-volumen-en-contenedor)
  - [Crear contenedor con volumen automático](#crear-un-contenedor-que-a-su-vez-crea-un-volumen)
  - [Compartir volúmenes entre contenedores](#asociar-el-volúmens-a-varios-contenedores)
  - [Inspeccionar volúmenes](#inspeccionar-el-volumen)
  - [Eliminar volúmenes](#eliminar-un-volumen-específico)
- [🧠 Tmpfs mount](#-tmpfs-mount)
- [📊 Monitorización](#-monitorización)
  - [Eventos en tiempo real](#eventos)
  - [Métricas de contenedores](#métricas-de-un-contenedor)
  - [Uso de disco](#cuánto-espacio-estamos-usando-del-disco-por-culpa-de-docker)
  - [Logs de contenedores](#cómo-ver-los-logs-de-un-contenedor)
- [🔌 Docker extensions](#-docker-extensions)

---

En algún momento tus contenedores morirán 😥 y tendrás que volver a crearlos. Si no has guardado los datos que tenían, perderás toda la información que almacenaban o generaron. Por eso es importante saber cómo gestionar el almacenamiento en Docker.

Existen diferentes formas de almacenar datos en Docker. En este módulo vamos a ver las siguientes:

- 🔗 **Bind mounts**: Enlace directo entre carpetas del host y contenedor
- 💾 **Volúmenes**: Almacenamiento persistente gestionado por Docker
- 🧠 **Tmpfs mount**: Almacenamiento temporal en memoria RAM

## 🔗 Bind mounts

Un bind mount es un enlace directo entre una carpeta en tu máquina y una carpeta en tu contenedor. Esto significa que si cambias algo en la carpeta local, también cambiará en la carpeta del contenedor y viceversa. 🔄

Para crear un bind mount, utiliza la opción `--mount` o `-v` al crear un contenedor. Por ejemplo:

### Crear bind mount con --mount

```bash
cd 01-contenedores/contenedores-iv

docker run -d --name halloween-web --mount type=bind,source="$(pwd)"/web-content,target=/usr/share/nginx/html/ -p 8080:80 nginx
```

Si analizamos este comando tenemos:

- 🐳 `docker run`: Crea y arranca un contenedor.
- 🌙 `-d`: Lo hace en segundo plano.
- 🏷️ `--name devtest`: Le pone nombre al contenedor.
- 📁 `--mount type=bind,source="$(pwd)"/web-content,target=/usr/share/nginx/html/`: Crea un bind mount. El tipo de montaje es bind, la carpeta de origen es la carpeta actual (`$(pwd)`) más `web-content` y la carpeta de destino es `/usr/share/nginx/html/`.

> [!NOTE]
> ✅ Es comendable utilizar la opción `--mount` en lugar de `-v` o `--volume` porque es más explícito y fácil de leer.

### Crear bind mount con -v

Si quisieras hacerlo con `-v`:

```bash
docker run -d --name halloween-web-v -v "$(pwd)"/web-content:/usr/share/nginx/html/ -p 8081:80 nginx
```

🔄 Si cambias el contenido de la carpeta `web-content` en tu máquina local, también cambiará en la carpeta `/usr/share/nginx/html/` en tu contenedor.

### 🚀 Ejemplo práctico: Desarrollo en vivo

Vamos a ver el poder de los bind mounts para desarrollo. Con el contenedor corriendo, edita el archivo `web-content/index.html`:

```bash
# Edita el archivo (puedes usar cualquier editor)
echo "<h1>¡Cambio en vivo!</h1><p>Hora actual: $(date)</p>" > web-content/index.html

# Recarga la página en http://localhost:8081 y verás el cambio inmediatamente
```

**🎯 Casos de uso reales para bind mounts:**
- **Desarrollo web**: Cambios instantáneos sin rebuild
- **Configuración**: Archivos de config externos al contenedor
- **Logs**: Acceder a logs desde el host
- **Scripts**: Ejecutar scripts del host en contenedor

⚠️ **Limitaciones en producción:**
- Dependencia del filesystem del host
- Problemas de permisos entre sistemas
- No funciona bien en clusters distribuidos

#### Usar el bind mount como read-only

También puedes montar un bind mount como read-only. Esto significa que desde tu máquina podrás cambiar el contenido sin problemas pero desde dentro del contenedor no se podrá. 🔒 Para hacerlo, añade la opción `readonly` al comando `--mount`. Por ejemplo:

```bash
docker run -d --name halloween-readonly --mount type=bind,source="$(pwd)"/web-content,target=/usr/share/nginx/html/,readonly -p 8082:80 nginx
```

Como está en modo lectura, en teoría no podría crear ningún archivo dentro del directorio donde está montada mi carpeta local:

```bash
docker container exec -it halloween-readonly sh
ls /usr/share/nginx/html
touch /usr/share/nginx/html/index2.html 
exit
```

⚠️ El problema principal que tienen los montajes de tipo `bind` es que no son portables. Si tienes un contenedor en un host y quieres moverlo a otro, tendrás que mover también la carpeta que estás montando.

## 💾 Volúmenes

Los volúmenes son una forma de almacenar datos de forma persistente en Docker. Estos volúmenes se almacenan en una carpeta en el host y se pueden compartir entre varios contenedores. 📁 El path donde se almacenan los volúmenes en el host es `/var/lib/docker/volumes` y lo gestiona Docker.

### Crear un volumen

Para crear un volumen, utiliza el comando `docker volume create` seguido del nombre del volumen. Por ejemplo:

```bash
docker volume create halloween-data
```

📊 Para comprobar cuántos volúmenes tienes en tu host puedes utilizar este comando:

```bash
docker volume ls
```

### Usar volumen en contenedor

Si quisieramos utilizar este volumen en un contenedor, podríamos hacerlo de la siguiente manera:

```bash
docker run -d --name halloween-with-volume --mount source=halloween-data,target=/usr/share/nginx/html/ -p 8083:80 nginx
```

En este caso el volumen `halloween-data` se ha montado en la carpeta `/usr/share/nginx/html/` del contenedor `halloween-volume`.

Sin embargo, en este caso deberíamos de copiar dentro de este volumen el contenido que queramos la primera vez:

```bash
docker cp web-content/. halloween-with-volume:/usr/share/nginx/html/
```

### Crear un contenedor que a su vez crea un volumen

También es posible crear un contenedor que a su vez cree un volumen. ✨

```bash
docker run -d --name halloween-demo -v web-data:/usr/share/nginx/html/ -p 8084:80 nginx
```

En este caso, al ejecutarse el contenedor `halloween-demo` se creará un volumen llamado `web-data` que se montará en la carpeta `/usr/share/nginx/html/` del contenedor.

Y de nuevo, añadir los datos a nuestro volumen:

```bash
docker cp web-content/. halloween-demo:/usr/share/nginx/html/
```

### Asociar el volúmens a varios contenedores

Puedes asociar varios contenedores al mismo volumen a la vez 🔄

```bash
docker container run -dit --name second-halloween-web --mount source=halloween-data,target=/usr/share/nginx/html -p 8085:80 nginx
```

Si quisieras comprobar a qué contenedores está asociado un volumen:

```bash	
docker ps --filter volume=halloween-data --format "table {{.Names}}\t{{.Mounts}}"
```

### Inspeccionar el volumen

Al inspeccionar cualquiera de los volúmenes podemos ver cuál es la ruta donde se están almacenando: 🔍

```bash
docker volume inspect halloween-data
```

### Eliminar un volumen específico

Para eliminar un volumen específico, utiliza el comando `docker volume rm` seguido del nombre del volumen. Por ejemplo:

```bash
docker volume rm halloween-data
```

⚠️ No puedes eliminar un volumen si hay un contenedor que lo tiene atachado. Te dirá que está en uso.

### Eliminar todos los volumenes que no esté atachados a un contenedor

🚨 Cuidado con este comando porque eliminará todos los volúmenes que no estén atachados a un contenedor. Para eliminar todos los volúmenes que no estén atachados a un contenedor, utiliza el comando `docker volume prune` seguido de la opción `-f`. Por ejemplo:

```bash
docker volume prune -f
```

### 📦 Backup y restore de volúmenes

Los volúmenes son críticos para la persistencia de datos. Aquí te mostramos cómo hacer backup y restore:

#### Crear un backup de un volumen

```bash
# Crear un contenedor temporal para hacer backup
docker run --rm -v halloween-data:/data -v $(pwd):/backup alpine \
  tar czf /backup/halloween-data-backup.tar.gz -C /data .

# Verificar que el backup se creó
ls -la halloween-data-backup.tar.gz
```

#### Restaurar desde un backup

```bash
# Crear un nuevo volumen
docker volume create halloween-data-restored

# Restaurar los datos
docker run --rm -v halloween-data-restored:/data -v $(pwd):/backup alpine \
  tar xzf /backup/halloween-data-backup.tar.gz -C /data

# Verificar la restauración
docker run --rm -v halloween-data-restored:/data alpine ls -la /data
```

### 🔄 Migración de datos entre volúmenes

A veces necesitas mover datos de un volumen a otro:

```bash
# Copiar datos de un volumen a otro
docker run --rm -v halloween-data:/source -v new-volume:/destination alpine \
  sh -c "cp -r /source/* /destination/"
```

### 💡 Comparación: Bind mounts vs Volúmenes

| Característica | Bind Mounts | Volúmenes |
|---------------|-------------|-----------|
| **Portabilidad** | ❌ Depende del host | ✅ Gestionado por Docker |
| **Desarrollo** | ✅ Ideal | ⚠️ Menos directo |
| **Producción** | ⚠️ Problemático | ✅ Recomendado |
| **Backup** | 🤷 Manual | ✅ Herramientas Docker |
| **Permisos** | ⚠️ Complejos | ✅ Gestionados |
| **Rendimiento** | ✅ Directo | ✅ Optimizado |

## 🧠 Tmpfs mount

La última forma de almacenar datos en Docker es utilizando un tmpfs mount. Un tmpfs mount es un sistema de archivos temporal que se almacena en la memoria RAM de tu host. ⚡ Esto significa que si apagas tu máquina, perderás todos los datos que hayas almacenado en tu contenedor.

```bash
docker run -dit --name tmptest --mount type=tmpfs,destination=/usr/share/nginx/html/ -p 8086:80 nginx
docker container inspect tmptest 
```

También se puede usar el parámetro `--tmpfs`:

```bash	
docker run -dit --name tmptest2 --tmpfs /app nginx:latest
```

```bash	
docker container inspect tmptest2 | grep "Tmpfs" -A 2
```

### 🎯 Casos de uso para tmpfs

**¿Cuándo usar tmpfs mount?**
- **Datos temporales**: Cachés, archivos temporales
- **Información sensible**: Passwords, tokens (se borran al apagar)
- **Alto rendimiento**: Operaciones que requieren I/O muy rápido
- **Testing**: Datos que no necesitas persistir

**Ejemplo práctico con cache:**

```bash
# Contenedor con cache en memoria
docker run -dit --name redis-cache \
  --tmpfs /data \
  -p 6379:6379 \
  redis:alpine redis-server --dir /data

# Verificar que funciona
docker exec redis-cache redis-cli ping
```

> [!WARNING]
> ⚠️ **Importante**: Todo en tmpfs se pierde al reiniciar el contenedor. Úsalo solo para datos que puedes permitirte perder.


## 📊 Monitorización 

En Docker podemos monitorizar los contenedores y los volúmenes. Para ello, Docker nos proporciona una serie de comandos que nos permiten ver en tiempo real lo que está ocurriendo en nuestro host. 👀

### Eventos

Uno de ellos es el comando `docker events`. Este comando nos permite ver en tiempo real los eventos que están ocurriendo en nuestro host. 🎬 Por ejemplo, si creamos un contenedor, veremos un evento de tipo `create` y si eliminamos un contenedor, veremos un evento de tipo `destroy`.

Para hacer la prueba de esto, abre un terminal y ejecuta el siguiente comando:

```bash
docker events
```

Ahora abre otro terminal y crea un contenedor:

```bash
docker run -d --name prueba -d ubuntu sleep 100
```

Ahora crea un volumen:

```bash
docker volume create prueba
```

Ahora descarga una imagen:

```bash
docker pull busybox
```

### Métricas de un contenedor

Otro dato que podemos ver es el uso de CPU, memoria y red de un contenedor. 📈 Para ello, Docker nos proporciona el comando `docker stats`. Este comando nos permite ver en tiempo real el uso de CPU, memoria y red de un contenedor.

Para verlo, vamos a crear un contenedor que haga ping a un servidor. Para ello, ejecuta el siguiente comando:

```bash
docker run --name ping-service alpine ping docker.com 
```

Y ahora ejecuta el siguiente comando:

```bash
docker stats ping-service
```

💡 Esta información también puedes verla en Docker Desktop, haciendo clic sobre el contenedor y seleccionando la pestaña de Stats.

### Cuánto espacio estamos usando del disco por "culpa" de Docker

Otro comando que puede ser útil es el que nos dice cuánto espacio estamos usando del disco por "culpa" de Docker: 💽

```bash
docker system df
```

### Cómo ver los logs de un contenedor

Aunque ya lo vimos en alguna clase anterior, es importante recordar que para ver los logs de un contenedor, podemos utilizar el comando `docker logs`. 📄 Por ejemplo, si queremos ver los logs del contenedor `ping-service`, ejecuta el siguiente comando:

```bash
docker logs ping-service
```

### 📊 Logs avanzados: Filtros y formatos

Docker logs tiene opciones muy útiles para analizar problemas:

```bash
# Ver solo las últimas 10 líneas
docker logs --tail 10 ping-service

# Seguir logs en tiempo real (como tail -f)
docker logs -f ping-service

# Ver logs con timestamps
docker logs -t ping-service

# Filtrar logs por tiempo
docker logs --since="2024-01-01T00:00:00" ping-service
docker logs --until="2024-12-31T23:59:59" ping-service

# Combinar opciones
docker logs -f --tail 20 -t ping-service
```

### 🚨 Troubleshooting con logs

**Buscar errores comunes:**

```bash
# Buscar errores en logs
docker logs ping-service 2>&1 | grep -i error

# Ver logs de contenedor que falló
docker logs --details container-that-failed

# Analizar logs de múltiples contenedores
docker logs $(docker ps -q) 2>&1 | grep -i "warning\|error"
```

### 🔧 Limpieza inteligente del sistema

Además de `docker system df`, puedes hacer limpieza selectiva:

```bash
# Limpiar todo lo no utilizado (¡cuidado!)
docker system prune -a

# Limpiar solo imágenes sin usar
docker image prune

# Limpiar solo contenedores parados
docker container prune

# Limpiar solo volúmenes no utilizados
docker volume prune

# Ver qué se eliminaría sin hacerlo
docker system prune --dry-run
```

### 📈 Monitorización avanzada

**Monitoring de múltiples contenedores:**

```bash
# Stats de todos los contenedores
docker stats

# Stats con formato personalizado
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

# Solo un contenedor específico cada 2 segundos
docker stats --no-stream ping-service
```

**Alertas básicas con scripts:**

```bash
# Script simple para alertar si CPU > 80%
#!/bin/bash
CPU_USAGE=$(docker stats --no-stream --format "{{.CPUPerc}}" ping-service | sed 's/%//')
if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
    echo "⚠️ ALERTA: CPU al ${CPU_USAGE}%"
fi
```


## 💾 Limitar recursos: CPU y Memoria

Es importante limitar los recursos que puede usar un contenedor para evitar que consuma todos los recursos del host y afecte a otros contenedores o servicios.

### 📊 Limitar Memoria (`--memory` o `-m`)

Especifica la cantidad máxima de memoria RAM que puede usar el contenedor:

```bash
docker run -d --memory="512m" --name web -p 8080:80 httpd
```

**Formatos válidos:**
- `512m` - 512 megabytes
- `1g` - 1 gigabyte
- `2g` - 2 gigabytes

**🔍 Cómo funciona:**
- El contenedor puede usar hasta la cantidad especificada
- Si intenta exceder el límite, Docker lo mata (OOM - Out of Memory)
- Sin límite especificado, puede usar toda la RAM disponible

### ⚙️ Limitar CPU (`--cpus`)

Especifica cuántos núcleos de CPU puede usar el contenedor:

```bash
docker run -d --cpus="1.5" --name web -p 8080:80 httpd
```

**Ejemplos de uso:**
- `--cpus="1"` - Usar como máximo 1 núcleo CPU completo
- `--cpus="0.5"` - Usar el 50% de 1 núcleo (compartido)
- `--cpus="2"` - Usar 2 núcleos completos

**🔍 Cómo funciona:**
- El contenedor puede usar hasta ese número de núcleos
- Si hay más disponibles, puede usarlos cuando otros contenedores no los necesitan
- Sin límite especificado, puede usar todos los núcleos

### 📋 Limitar CPU Priority (`--cpu-shares`)

Controla la prioridad de CPU en caso de contención:

```bash
docker run -d --cpu-shares=1024 --name web -p 8080:80 httpd
```

**Por defecto:** Cada contenedor tiene 1024 shares
- Si todos los contenedores tienen 1024, comparten CPU equitativamente
- Si uno tiene 512 y otro 1024, el de 1024 recibe el doble de CPU cuando hay contención

### 🔗 Combinando límites de CPU y Memoria

**Ejemplo práctico: Servidor web seguro**

```bash
docker run -d \
  --name production-web \
  --memory="2g" \
  --cpus="1.5" \
  --cpu-shares=1024 \
  -p 8080:80 \
  httpd
```

**Esto significa:**
- ✅ Máximo 2GB de RAM
- ✅ Máximo 1.5 núcleos de CPU
- ✅ Prioridad normal en caso de contención

### 📊 Ver uso de recursos en tiempo real

```bash
# Ver estadísticas de un contenedor específico
docker stats web

# Ver estadísticas de todos los contenedores
docker stats

# Ver con formato personalizado
docker stats --no-stream
```

**🎯 Casos de uso comunes:**

| Caso | Configuración |
|------|---------------|
| Servidor web de producción | `--memory="2g" --cpus="2"` |
| Base de datos | `--memory="4g" --cpus="4"` |
| Aplicación pequeña/prueba | `--memory="256m" --cpus="0.5"` |
| Tarea background | `--memory="512m" --cpus="0.25"` |

**⚠️ Importante:**
- Si no especificas límites, el contenedor puede consumir todos los recursos
- Establecer límites muy bajos puede hacer que la aplicación vaya lenta
- Monitorea siempre el uso real vs los límites establecidos

**💡 Recomendación:** Para aplicaciones en producción, siempre establece límites de memoria y CPU para proteger la estabilidad del sistema.

## 🔌 Docker extensions

Existen varias extensiones de Docker que nos permiten monitorizar nuestros contenedores de una forma más visual. 🎨 Puedes encontrarlas en el apartado de extensiones de Docker Desktop o a través del marketplace: https://hub.docker.com/search?q=&type=extension&sort=pull_count&order=desc

### 🌟 Extensiones recomendadas

**Para monitorización:**
- **Disk usage**: Visualiza el uso de espacio de Docker
- **Logs Explorer**: Interfaz avanzada para análisis de logs
- **Resource Usage**: Gráficos de CPU, memoria y red

**Para desarrollo:**
- **Volumes Backup & Share**: Backup y compartir volúmenes fácilmente
- **Docker Scout**: Análisis de vulnerabilidades en imágenes

### 🎯 Ejercicios prácticos para consolidar

**Ejercicio 1: Setup de desarrollo completo**
```bash
# 1. Crear un bind mount para desarrollo web
# 2. Editar archivos en vivo y ver cambios
# 3. Configurar logs en tiempo real
# 4. Monitorizar recursos mientras desarrollas
```

**Ejercicio 2: Gestión de datos empresarial**
```bash
# 1. Crear volúmenes para datos persistentes
# 2. Hacer backup de volúmenes
# 3. Simular fallo y recuperación
# 4. Compartir datos entre múltiples servicios
```

**Ejercicio 3: Optimización y monitorización**
```bash
# 1. Usar tmpfs para cachés temporales
# 2. Monitorizar uso de recursos
# 3. Analizar logs para troubleshooting
# 4. Limpiar sistema manteniendo lo esencial
```

> [!TIP]
> 💡 **Consejo final**: En producción, siempre usa volúmenes para datos críticos, bind mounts solo para desarrollo, y tmpfs para datos temporales que requieren alto rendimiento.

<!--
## ⏱️ Distribución temporal sugerida (3 horas)

**Primera hora (60 min):**
- 🔗 Bind mounts completo (45 min)
  - Explicación conceptual (10 min)
  - Práctica con --mount (15 min) 
  - Práctica con -v (10 min)
  - Read-only bind mount (10 min)
- ☕ Mini break (15 min)

**Segunda hora (60 min):**
- 💾 Volúmenes - Parte 1 (60 min)
  - Crear y usar volúmenes básicos (30 min)
  - Volúmenes automáticos (15 min)
  - Compartir entre contenedores (15 min)

**Tercera hora (60 min):**
- 💾 Volúmenes - Parte 2 (20 min)
  - Inspección y limpieza
- 🧠 Tmpfs mount (15 min)
- 📊 Monitorización (20 min)
  - Sesión práctica con docker events, stats, logs
- 🔌 Docker extensions + tiempo libre (5 min)

**Tiempo de buffer: ~30 minutos** - Perfecto para experimentación extra
-->
