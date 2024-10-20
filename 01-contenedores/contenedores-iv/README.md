# Día 4: Almacenamiento en Docker

![Docker](imagenes/Cómo%20gestionar%20el%20almacenamiento%20en%20Docker.jpeg)


En algún momento tus contenedores morirán 😥 y tendrás que volver a crearlos. Si no has guardado los datos que tenían, perderás toda la información que almacenaban o generaron. Por eso es importante saber cómo gestionar el almacenamiento en Docker.

Existen diferentes formas de almacenar datos en Docker. En este módulo vamos a ver las siguientes:

- Bind mounts
- Volumenes
- Tmpfs mount

## Bind mounts

Un bind mount es un enlace directo entre una carpeta en tu máquina y una carpeta en tu contenedor. Esto significa que si cambias algo en la carpeta local, también cambiará en la carpeta del contenedor y viceversa.

Para crear un bind mount, utiliza la opción `--mount` o `-v` al crear un contenedor. Por ejemplo:

```bash
cd 01-contenedores/contenedores-iv

docker run -d --name devtest --mount type=bind,source="$(pwd)"/dev-folder,target=/usr/share/nginx/html/ -p 8080:80 nginx
```

Si analizamos este comando tenemos:

- `docker run`: Crea y arranca un contenedor.
- `-d`: Lo hace en segundo plano.
- `--name devtest`: Le pone nombre al contenedor.
- `--mount type=bind,source="$(pwd)"/dev-folder,target=/usr/share/nginx/html/`: Crea un bind mount. El tipo de montaje es bind, la carpeta de origen es la carpeta actual (`$(pwd)`) más `dev-folder` y la carpeta de destino es `/usr/share/nginx/html/`.

> [!NOTE]
> Es comendable utilizar la opción `--mount` en lugar de `-v` o `--volume` porque es más explícito y fácil de leer.


Si cambias el contenido de la carpeta `dev-folder` en tu máquina local, también cambiará en la carpeta `/usr/share/nginx/html/` en tu contenedor.

#### Usar el bind mount como read-only

También puedes montar un bind mount como read-only. Esto significa que desde tu máquina podrás cambiar el contenido sin problemas pero desde dentro del contenedor no se podrá. Para hacerlo, añade la opción `readonly` al comando `--mount`. Por ejemplo:

```bash
docker rm -f devtest
docker run -d --name devtest --mount type=bind,source="$(pwd)"/dev-folder,target=/usr/share/nginx/html/,readonly -p 8080:80 nginx
docker inspect devtest
```

Como está en modo lectura, en teoría no podría crear ningún archivo dentro del directorio donde está montada mi carpeta local:

```bash
docker container exec -it devtest sh
ls /usr/share/nginx/html
touch /usr/share/nginx/html/index2.html 
exit
```

El problema principal que tienen los montajes de tipo `bind` es que no son portables. Si tienes un contenedor en un host y quieres moverlo a otro, tendrás que mover también la carpeta que estás montando.

## Volúmenes

Los volúmenes son una forma de almacenar datos de forma persistente en Docker. Estos volúmenes se almacenan en una carpeta en el host y se pueden compartir entre varios contenedores. El path donde se almacenan los volúmenes en el host es `/var/lib/docker/volumes`y lo gestiona Docker.

### Crear un volumen

Para crear un volumen, utiliza el comando `docker volume create` seguido del nombre del volumen. Por ejemplo:

```bash
docker volume create lemoncode-data
```

Para comprobar cuántos volúmenes tienes en tu host puedes utilizar este comando:

```bash
docker volume ls
```

Si quisieramos utilizar este volumen en un contenedor, podríamos hacerlo de la siguiente manera:

```bash
docker run -d --name devtest2 --mount source=lemoncode-data,target=/usr/share/nginx/html/ -p 8081:80 nginx
```

En este caso el volumen `lemoncode-data` se ha montado en la carpeta `/usr/share/nginx/html/` del contenedor `devtest2`.

### Crear un contenedor que a su vez crea un volumen

También es posible crear un contenedor que a su vez cree un volumen.

```bash
docker run -d --name devtest3 -v web-data:/usr/share/nginx/html/ -p 8082:80 nginx
```

En este caso, al ejecutarse el contenedor `devtest3` se creará un volumen llamado `web-data` que se montará en la carpeta `/usr/share/nginx/html/` del contenedor.

Estos volumenes de primeras no tienen datos. En el caso de los contenedores que utilizan la imagen `nginx` se creará un fichero `index.html` por defecto. Si queremos añadir datos a nuestro volumen, podemos hacerlo de la siguiente manera:

```bash
docker cp web-content/. devtest3:/usr/share/nginx/html/
```


### Asociar el volúmens a varios contenedores

Puedes asociar varios contenedores al mismo volumen a la vez

```bash
docker container run -dit --name my-container2 \
    --mount source=my-data,target=/vol2 \
    alpine
```

#Para comprobar a qué contenedores está asociado un volumen
docker ps --filter volume=my-data --format "table {{.Names}}\t{{.Mounts}}"

#Inspeccionar el volumen
docker volume inspect my-data

#En Mac y Windows no podemos ver el contenido de la ruta donde se guardan los volúmenes. 
#En Linux podríamos:
ssh gis@137.135.216.143

#Creamos en este tipo de host los volumenes anteriores, si no estás trabajando en Linux
sudo docker container run -dit --name my-container \
    --mount source=my-data,target=/vol \
    alpine
sudo docker volume create data

#Al inspeccionar cualquiera de los volúmenes podemos ver cuál es la ruta donde se están almacenando
sudo docker volume inspect my-data
#Esta es la ruta donde Docker almacena los volúmenes
sudo ls -l /var/lib/docker/volumes
exit

#Ahora vamos a añadir algunos datos a nuestro volumen
docker container exec -it my-container sh
echo "Hola Lemoncoders!" > /vol/file1
ls -l /vol
cat /vol/file1
exit

#Ahora voy a eliminar el contenedor
docker rm my-container -f

#Pero el volumen todavía existe
docker volume ls

#Por lo que puedo crear un nuevo contenedor y volver a atachar el volumen que tenía con mis datos
docker container run -dit --name another-container \
    --mount source=my-data,target=/vol \
    alpine

#Comprueba que tu archivo file1 sigue ahí
docker container exec -it another-container sh
ls -l /vol
cat /vol/file1
exit



####  Backups ####
#Creo un contenedor con un volumen llamado dbdata. En este caso voy a utilizar la opción -v en lugar de --mount
docker run -dit -v dbdata:/dbdata --name dbstore ubuntu /bin/bash

#Compruebo que efectivamente el volumen dbdata se ha generado utilizando el parámetro -v
docker volume ls

#Ahora copio algunos ficheros dentro del volumen
docker cp some-files/. dbstore:/dbdata

#Compruebo que los archivos están ahí
docker exec dbstore ls /dbdata

#Creo un nuevo contenedor y monto el volumen del contenedor dbstore
#Ejecuto el comando tar que comprime el contenido
docker run --rm --volumes-from dbstore -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar /dbdata

#Eliminar un volumen específico 
docker volume rm data

#No puedes eliminar un volumen si hay un contenedor que lo tiene atachado. Te dirá que está en uso.
docker volume rm my-data

#Eliminar todos los volumenes que no esté atachados a un contenedor
docker volume prune -f


#Tmpfs mount
docker run -dit --name tmptest --mount type=tmpfs,destination=/usr/share/nginx/html/ nginx:latest
docker container inspect tmptest 

#También se puede usar el parámetro --tmpfs
docker run -dit --name tmptest2 --tmpfs /app nginx:latest

docker container inspect tmptest2 | grep "Tmpfs" -A 2


### Monitorización ###

# Eventos de docker
docker events

#Como los eventos son en tiempo real, necesitamos crear/modificar/eliminar algo que nos permita generar dichos eventos.
#Abre otro terminal y ejecuta estos comando:
docker run --name prueba -d ubuntu sleep 100
docker volume create prueba
docker pull busybox

#Métricas de un contenedor

#Puedes ver las métricas de un contenedor con docker stats. Este comando muestra CPU, memoria en uso, límite de memoria y red
docker run --name ping-service -d alpine ping docker.com 

docker stats ping-service

#Otro comando que puede ser útil es el que nos dice cuánto espacio estamos usando del disco por "culpa" de Docker
docker system df

#Recolectar métricas de Docker con Prometheus
#Docker Desktop for Mac / Docker Desktop for Windows: Click en el icono de Docker en la barra de Mac/Window, selecciona Preferencias > Docker Engine. Pega la siguiente configuración:  
{
  "metrics-addr" : "127.0.0.1:9323",
  "experimental" : true
}

#Con esta configuración Docker expondrá las metricas por el puerto 9323.
#Lo siguiente que necesitamos es ejecutar un servidor de Prometheus. El archivo prometheus-config.yml tiene la configuración de este.
docker run --name prometheus-srv --mount type=bind,source="$(pwd)"/prometheus-config.yml,target=/etc/prometheus/prometheus.yml -p 9090:9090 prom/prometheus

#Ahora puedes acceder a tu servidor de Prometheus a través de http://localhost:9090. Verás que aparece en Targets pero no podrás acceder a los endpoints si utilizas Docker for Mac/Windows
#Para comprobar que las gráficas funcionan correctamente, genera N contenedores que estén haciendo continuamente ping
docker run -d alpine ping docker.com 

#Verás que la gráfica con la métrica engine_daemon_network_actions_seconds_count genera picos. Después de haberlo probado elimina los contenedores

#Ver esta información en un Dashboard de Grafana
docker run -d -p 3000:3000 grafana/grafana

#Cómo ver los logs de un contenedor
docker logs devtest

#docker logs en fluentd

#Archivo de configuración de fluentd
cat fluentd/in_docker.conf

#Inicia fluentd en un contenedor. Utilizo bind mount para montar el contenido de in_docker.conf en el archivo fluentd/etc/fluent.conf
#asegurate de que estás en 01-contenedores/contenedores-v
docker run -it -p 24224:24224 -v "$(pwd)"/fluentd/in_docker.conf:/fluentd/etc/test.conf -e FLUENTD_CONF=test.conf fluent/fluentd:latest

#Arranca un contenedor y lanza algunos mensajes a la salida estándar
docker run --rm -p 3030:80 --log-driver=fluentd nginx

#UI para ver los logs de Fluentd
docker run -d -p 9292:9292 -p 24224:24224 dvladnik/fluentd-ui #copia el contenido del archivo de configuración en 