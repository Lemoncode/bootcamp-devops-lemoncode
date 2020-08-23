# Parte 4: Networking #

#Listar las redes disponibles en este host
docker network ls

#Por defecto, ya hay una red creada en un host de Docker (En Linux se llama bridge y el Docker se llama nat)

#De forma predeterminada, esta es la red  a la que se conectarán todos los contenedores para los que no especifiquemos una red a través de --network
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

#Atacha el termina a container-b y haz un ping al container-a utilizando su nombre
docker exec -it container-b sh
ping container-a
exit

#Las redes de tipo bridge nos permiten que los contenedores puedan comunicarse entre ellos de una forma sencilla. 
#No obstante podemos utilizar Port Mapping para exponer contenedores y que estos sean accesibles desde el exterior
docker container run -d --name web \
   --network localnet \
   --publish 5000:80 \
   nginx

#Para verificar los puertos mapeados de un contenedor
docker port web

#Eliminar todos las redes que están en desuso en un host
docker network prune

#Crear una red de tipo overlay
docker network create -d overlay multihost-net

#Veras que la misma se ha creado con el driver overlay
docker network ls

#TODO: mostrar el ejemplo con dos Docker host y ver cómo un contenedor en el host 1 se puede comunicar con un contenedor en el host 2 de la misma forma que vimos anteriormente





#Deberes:
# 1. 
# 2. 
# 3.
