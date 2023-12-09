# Parte 4: Volúmenes #

cd 01-contenedores/contenedores-iv

#Listar los volumenes en el host
docker volume ls

#Crear un nuevo volumen con create
docker volume create data
docker volume ls

#Crear un contenedor que a su vez crea un volumen
docker container run -dit --name my-container \
    --mount source=my-data,target=/vol \
    alpine

#Se puede utilizar tanto --mount como -v (o --volume)). Originalmente --mount solo se usaba para el modo clúster. Sin embargo, desde la versión 17.06 (Vamos por la 10.03.13) 
# se puede utilizar para contenedores independientes.


#Puedes comprobar que el volumen se ha creado correctamente
docker volume ls

#Puedo asociar varios contenedores al mismo volumen a la vez
docker container run -dit --name my-container2 \
    --mount source=my-data,target=/vol2 \
    alpine

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


## Bind mounts ##

#Se utiliza cuando quieres montar un archivo o directorio dentro de un contenedor
cd 01-contenedores/contenedores-iv

#dev-folder es el directorio que voy a montar dentro de mi contenedor
#con pwd recupero la carpeta actual
pwd
docker run -d --name devtest --mount type=bind,source="$(pwd)"/dev-folder,target=/usr/share/nginx/html/ -p 8080:80 nginx
docker inspect devtest
#Ahora cambia en el host el contenido de la carpeta dev-folder

#Usar el bind mount como read-only
docker rm -f devtest
docker run -d --name devtest --mount type=bind,source="$(pwd)"/dev-folder,target=/usr/share/nginx/html/,readonly -p 8080:80 nginx
docker inspect devtest

#Como está en modo lectura, en teoría no podría crear ningún archivo dentro del directorio donde está montada mi carpeta local
docker container exec -it devtest sh
ls /usr/share/nginx/html
touch /usr/share/nginx/html/index2.html #Dará error porque el montaje está en modo read-only
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