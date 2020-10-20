# Parte 4: Networking #

#Lo que habíamos visto hasta ahora: Port Mapping

#Vimos el ejemplo con Nginx, en el que mapeábamos un puerto del host al puerto 80, que es el que teníamos configurado como servidor web.
docker run -d -p 9090:80 nginx

#Podemos aprovecharnos de la información de EXPOSE para publicar todos los puertos que
#Utiliza el contenedor
#A través de inspect puedo saber qué puertos utilizará esta imagen
docker inspect hello-world
docker run -d --name hello-world-with-a-lot-of-ports --publish-all hello-world:latest
#o bien
docker run -d --name hello-world-with-a-lot-of-ports -P hello-world:latest

#Para poder visualizar cuáles son los puertos expuestos y cuáles han sido asignados del host:
docker port hello-world-with-a-lot-of-ports

#En linux puedes ver que hay una interfaz más llamada docker0
ssh gis@137.135.216.143
ifconfig
exit

#Listar las redes disponibles en este host
docker network ls
#Por defecto, ya hay una red creada en un host de Docker (En Linux se llama bridge y el Docker se llama nat)

#Usando el bridge por defecto#
#Esta red no es la mejor opción para entornos productivos

#De forma predeterminada, esta es la red  a la que se conectarán todos los contenedores para los que NO especifiquemos una red a través de --network
docker network inspect bridge #En el apartado Containers es donde verás todos los contenedores que están conectados a esta red.

docker network inspect bridge --format '{{json .Containers}}' | jq

#A modo de ejemplo vamos a crear dos contenedores que se conecten a la red por defecto
docker run -dit --name container-1 alpine ash
docker run -dit --name container-2 alpine ash

#El comando -d significa que estos dos contenedores estarán desatachados del terminal. Sin embargo con -it indicamos
#que ambos serán interactivos (es decir que podemos escribir en el terminal de estos) y la t significa que podemos ver
#tanto lo que escribimos como lo que nos devuelve como resultado.
#ash es el shell que utiliza por defecto Alpine, en lugar de bash que se utiliza en otras distros.
docker ps

#Elimina el anterior para que quede más limpia la salida
docker rm -f hello-world-with-a-lot-of-ports
docker ps

#Inspeccionar la configuración de una red
docker network inspect bridge --format '{{json .Containers}}' | jq

#Conectate al primer contenedor alpine1
docker attach container-1
#visualiza las interfaces de red de este contenedor
ip addr show
#La primera interfaz es la llamada loopback, esta permite al contenedor hablar consigo mismo.
#La llamada eth0 es la que tiene la IP adjudicada para la red bridge
#Otra prueba que puedes hacer es comprobar que el contenedor está conectado a internet
ping -c 2 172.17.0.4
ping -c 2 container-2 #En la red por defecto, bridge, los contenedores no se conocen por su nombre, solo por la IP
exit


#Crear una nueva red
docker network create network-a

#Por defecto la crea de tipo bridge en Linux (y tipo NAT en Windows)
docker network ls

#Ahora crea un contenedor que esté asociado a tu nueva red
docker container run -dit --name container-a --network network-a alpine ash

#Con el siguiente comando puedes saber qué contenedores están asociados a una red
docker network inspect network-a --format '{{json .Containers}}' | jq

#Ahora vamos a añadir un segundo contenedor a nuestra nueva red
docker container run -dit --name container-b --network network-a alpine ash

#Ahora tienes dos contenedores dentro de la misma red:
docker network inspect network-a --format '{{json .Containers}}' | jq

#Atacha el terminal a container-b y haz un ping al container-a utilizando su nombre
docker attach container-b
ping -c 3 container-a
exit

#En las redes definidas por el usuario los contenedores no solo pueden comunicarse a través de su IP
#sino que también pueden hacerlo a través del nombre del contenedor

#Un contenedor con dos endpoints
#Para conectar un contenedor a una segunda, tercera, etc red necesitas hacerlo a posteriori.
#Es decir que solo puedes conectar un contenedor a una sola red en el momento de su creación con docker run
docker network create network-b
docker container run -dit --name container-c --network network-b alpine ash
docker network connect network-b container-b

#Revisa los contenedores que tienes
docker ps

#Inspecciona qué contenedores tienes en cada red
docker network inspect network-a --format '{{json .Containers}}' | jq
docker network inspect network-b --format '{{json .Containers}}' | jq

#El contenedor a y b están en localnet y b también está en localnet-2

#Por lo tanto, el contenedor b podrá hablar tanto con el a, al estar ambos en localnet, y con el c, al estar ambos en localnet-2
docker attach container-b
ping -c 2 container-a
ping -c 2 container-c

#Sin embargo, el A no podrá hablar con el C
docker attach container-a
ping -c 2 container-c
#Solo con el b
ping -c 2 container-b



#Por otro lado, si conectamos al container-b a la red bridge también
docker network connect bridge container-b
#E intentamos hacer un ping al contenedor alpine2 no podremos hacerlo a través de su nombre
docker attach container-b
ping container-1
#Tendremos que usar su IP
ping -c 3 172.17.0.3
exit

# Red de tipo host
#Para este escenario necesito conectarme a un host Linux
ssh gis@137.135.216.143
#El objetivo es poder crear un contenedor con la imagen de nginx dentro de esta red 
#y comunicarme con él a través del puerto 80 de host directamente, sin mapeos.
sudo docker run --rm -d --network host --name my_nginx nginx
sudo docker ps
sudo netstat -tulpn | grep :80
curl 137.135.216.143
#Si paras el contenedor se eliminará automáticamente
sudo docker container stop my_nginx

#Deshabilitar completamente la red de un contenedor
docker run --rm -dit --network none --name no-net-alpine alpine ash
#Ahora comprueba que efectivamente no tienes eth0 creado, solo loopback
docker exec no-net-alpine ip link show
#Si paras el contenedor este será eliminado automáticamente, debido al flag --rm
docker stop no-net-alpine

#Eliminar todos las redes que están en desuso en un host
docker network prune

#Crear una red de tipo overlay
docker network create --driver overlay multihost-net
#Para poder crear redes del tipo overlay es necesario tener Docker en modo clúster (lo veremos en el último módulo)