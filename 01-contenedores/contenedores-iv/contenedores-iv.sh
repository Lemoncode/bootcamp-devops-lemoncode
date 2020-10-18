# Parte 4: Networking #

#Lo que habíamos visto hasta ahora: Port Mapping

#Vimos el ejemplo con Nginx, en el que mapeábamos un puerto del host al puerto 80, que es el que teníamos configurado como servidor web.
docker run -d -p 8080:80 nginx

#Podemos aprovecharnos de la información de EXPOSE para publicar todos los puertos que
#Utiliza el contenedor
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

#De forma predeterminada, esta es la red  a la que se conectarán todos los contenedores para los que NO especifiquemos una red a través de --network
docker network inspect bridge --format '{{json .Containers}}' | jq

#Inspeccionar la configuración de una red
docker network inspect bridge

#Crear una nueva red
docker network create localnet

#Por defecto la crea de tipo bridge en Linux (y tipo NAT en Windows)
docker network ls

#Ahora crea un contenedor que esté asociado a tu nueva red
docker container run -d --name container-a \
  --network localnet \
  alpine sleep 1d 


#Con el siguiente comando puedes saber qué contenedores están asociados a una red
docker network inspect localnet --format '{{json .Containers}}' | jq

#Ahora vamos a añadir un segundo contenedor a nuestra nueva red
docker container run -d --name container-b \
  --network localnet \
  alpine sleep 1d

#Ahora tienes dos contenedores dentro de la misma red:
docker network inspect localnet --format '{{json .Containers}}' | jq


#Atacha el terminal a container-b y haz un ping al container-a utilizando su nombre
docker exec -it container-b sh
ping container-a
exit

#TODO: Un contenedor con dos endpoints!!!! 

#Eliminar todos las redes que están en desuso en un host
docker network prune

#Crear una red de tipo overlay
docker network create --driver overlay multihost-net
#Para poder crear redes del tipo overlay es necesario tener Docker en modo clúster (lo veremos en el último módulo)