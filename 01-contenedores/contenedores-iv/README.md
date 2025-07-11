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

## 🔌 Docker extensions

Existen varias extensiones de Docker que nos permiten monitorizar nuestros contenedores de una forma más visual. 🎨 Puedes encontrarlas en el apartado de extensiones de Docker Desktop o a través del marketplace: https://hub.docker.com/search?q=&type=extension&sort=pull_count&order=desc
