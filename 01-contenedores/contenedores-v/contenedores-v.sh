# Parte 5: Networking #

#Listar las redes disponibles en este host
docker network ls
#Por defecto, ya hay una red creada en un host de Docker (En Linux se llama bridge y el Docker se llama nat)

#Usando el bridge por defecto#
#Esta red no es la mejor opción para entornos productivos

#De forma predeterminada, esta es la red  a la que se conectarán todos los contenedores para los que NO especifiquemos una red a través de --network
docker network inspect bridge #En el apartado Containers es donde verás todos los contenedores que están conectados a esta red.

# Creo un nuevo contenedor sin especificar la red
docker run -d --name web nginx

# BONUS: otra forma de mostrar el resultado
docker network inspect bridge --format '{{json .Containers}}' | jq

#Ahora creamos otro contenedor sin especificar tampoco la red, por lo tanto también se conectará a bridge
docker run -d --name web-apache httpd

#Comprobamos cuántos contenedores se están ejecutando
docker ps

#Inspeccionar la configuración de una red
docker network inspect bridge --format '{{json .Containers}}' | jq

#Conectate al contenedor web
docker exec -ti web /bin/bash

#En esta distribución de debian no está instalado net-tools
apt update && apt -y install net-tools iputils-ping
#Ver las interfaces de red del contenedor
ifconfig
#Hace ping al contenedor web-apache
ping 172.17.0.3
#Hace ping usando el nombre del contenedor
ping web-apache
#Salir del terminal asociado al contenedor
exit

#Crear una nueva red
docker network create lemoncode-net

#Por defecto la crea de tipo bridge en Linux (y tipo NAT en Windows)
docker network ls

#Inspeccionamos la nueva red
#En las redes definidas por el usuario los contenedores no solo pueden comunicarse a través de su IP
#sino que también pueden hacerlo a través del nombre del contenedor

docker network inspect lemoncode-net

# Creo un nuevo contenedor en la red lemoncode-net
docker run -d --name web2 --network lemoncode-net nginx

# Me conecto a un terminal como hice anteriormente
#Conectate al contenedor web
docker exec -ti web2 /bin/bash
#Instalo las herramientas
apt update && apt -y install net-tools iputils-ping
#Compruebo las interfaces de red
ifconfig
#Intento hacer ping a uno de los contenedores de la otra red
ping 172.17.0.2
#Salimos del terminal asociado al contenedor
exit

# Creo otro contenedor en la misma red que el anterior
docker run -d --name web-apache2 --network lemoncode-net httpd

#Inspeccionamos la nueva red
docker network inspect lemoncode-net

#Si vuelvo a conectarme al contenedor de antes
docker exec -ti web2 /bin/bash
#Hago ping al nuevo contenedor por IP
ping 172.18.0.3
#Hago ping a través del nombre del contenedor
ping web-apache2
#cURL al contenedor
curl http://web-apache2
#Salimos del terminal asociado al contenedor
exit

#¿Y si queremos que un contenedor esté en dos redes?
docker network connect bridge web2

#Inspeccionamos la red bridge para ver si está web2
docker network inspect bridge

#Vuelvo a conectarme al contenedor
docker exec -ti web2 /bin/bash
#Compruebo las interfaces de red
ifconfig
#Intento hacer ping a uno de los contenedores de la red bridge
ping 172.17.0.2
#Intento hacer ping a uno de los contenedores de la red bridge
ping 172.18.0.2

#Lo que habíamos visto hasta ahora: Port Mapping

#Vimos el ejemplo con Nginx, en el que mapeábamos un puerto del host al puerto 80, que es el que teníamos configurado como servidor web.
docker run -d -p 9090:80 nginx

#Creo una imagen súper sencilla que usa como base la de nginx
docker build -t nginx-custom .

#Inspecciono la imagen
docker inspect nginx-custom

#Podemos aprovecharnos de la información de EXPOSE para publicar todos los puertos que utiliza el contenedor
docker run -d --publish-all nginx-custom
#O bien 
docker run -d -P nginx-custom

#En docker ps se ven todos los puertos asociado
docker ps

#O más claro
docker port 1fc1f692cf14


# Red de tipo host
docker run -d --name web-apache3 --network host httpd
#Inspeccionamos la misma para ver si el contenedor está asociado a ella
docker network inspect host

#Deshabilitar completamente la red de un contenedor
docker run -dit --network none --name no-net-alpine alpine ash
#Ahora comprueba que efectivamente no tienes eth0 creado, solo loopback
docker exec no-net-alpine ip link show

#Eliminar una red
docker network rm lemoncode-net

#Eliminar todos las redes que están en desuso en un host
docker network prune

#Crear una red de tipo overlay
docker network create --driver overlay multihost-net
#Para poder crear redes del tipo overlay es necesario tener Docker en modo clúster (lo veremos en el último módulo)