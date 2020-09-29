# Parte 6: Docker Compose #
cd 01-contenedores/contenedores-vi

docker-compose up & #con el & al final te deja utilizar el terminal, además de ver la salida

#Parar y eliminar
docker-compose down

# Docker Swarm #

#Antes de trabajar con el orquestador Docker Swarm es necesario crear el cluster a través del siguiente comando:
docker swarm init
#El primer nodo que lance este comando se convertirá en master. El terminal devolverá el comando a ejecutar para unir workers, y masters, al cluster
#Cuando trabajas con Windows y Mac se están utilizando virtualizaciones para Docker por lo que no es posible probar este escenario. es fácil verlo porque el comando anterior devuelve una IP que no es la de tu máquina local.

#Docker Machine
https://docs.docker.com/machine/overview/
#Se trata de una herramienta que te permite instalar Docker Engine en host virtuales y administrarlos
#con el comando docker-machine.
#Puedes usarlo con Mac, Windows, en la red de tu empresa, con proveedores cloud, etc.
#Cómo instalarlo en Mac
base=https://github.com/docker/machine/releases/download/v0.16.0 && \
  curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/usr/local/bin/docker-machine && \
  chmod +x /usr/local/bin/docker-machine

#Windows (Git bash)
base=https://github.com/docker/machine/releases/download/v0.16.0 &&
  mkdir -p "$HOME/bin" &&
  curl -L $base/docker-machine-Windows-x86_64.exe > "$HOME/bin/docker-machine.exe" &&
  chmod +x "$HOME/bin/docker-machine.exe"

#Comprueba que la instalación se ha hecho correctamente
docker-machine version

#Cómo crear una máquina con Docker Engine con docker-machine
#Virtual Box
docker-machine create --driver virtualbox master-0
#Hyper-V
docker-machine create --driver hyperv master-0

#Listar las máquinas que están ejecutándose
docker-machine ls

#Conectar tu Docker Client a master-0
docker-machine env master-0
eval $(docker-machine env master-0)
docker-machine status master-0
docker-machine url master-0
docker ps
docker info #Comprueba que el nombre de la máquina sea el mismo que elegiste en la creación con docker-machine
#Comprueba que las variables de entorno apuntan a la máquina creada
env | grep DOCKER

#Ejecuta un contenedor en la máquina que tienes como contexto
docker run busybox echo hello world

#Recuperar la IP de uno de los nodos
docker-machine ip master-0

#Ejecutar un Nginx 
docker run -d -p 8000:80 nginx

#Hacer una petición al servidor web
curl $(docker-machine ip master-0):8000

#Parar una máquina
docker-machine stop master-0

#Iniciar una máquina
docker-machine start master-0

#Para hacer que el terminal vuelva a apuntar a Docker Desktop
docker-machine env -u
eval $(docker-machine env -u)
env | grep DOCKER
docker info #volverás a apuntar a Docker Desktop

#Crear un cluster con Docker Swarm y Docker Machine
docker-machine create --driver virtualbox master-1
docker-machine create --driver virtualbox master-2
docker-machine create --driver virtualbox worker-0
docker-machine create --driver virtualbox worker-1

#Ver el resumen de todas las máquinas creadas
docker-machine ls

#Si abres Virtual Box verás que efectivamente tienes creadas todas esas máquinas.

#Ahora en el master-0 iniciamos el cluster con Docker Swarm
eval $(docker-machine env master-0)
docker swarm init --advertise-addr 192.168.99.108

#En master-1 y master-2 los unimos como master
docker swarm join-token manager
eval $(docker-machine env master-1)
docker swarm join --token SWMTKN-1-3czeva7osjv5mxe699jlph03lcsd75del6v5hgfi62r7v9vw8r-09gviao4tsmo3suwpbucqpqqu 192.168.99.108:2377
eval $(docker-machine env master-2)
docker swarm join --token SWMTKN-1-3czeva7osjv5mxe699jlph03lcsd75del6v5hgfi62r7v9vw8r-09gviao4tsmo3suwpbucqpqqu 192.168.99.108:2377
#Chequeamos el estado actual del cluster
docker node ls

#Por ahora solo tenemos masters pero no curris, nos faltan los workers.

#En worker-0 y worker-1 los unimos como workers
eval $(docker-machine env worker-0)
docker swarm join --token SWMTKN-1-3czeva7osjv5mxe699jlph03lcsd75del6v5hgfi62r7v9vw8r-1ynw61hj7of7ix4dfhijgzfgt 192.168.99.108:2377
eval $(docker-machine env worker-1)
docker swarm join --token SWMTKN-1-3czeva7osjv5mxe699jlph03lcsd75del6v5hgfi62r7v9vw8r-1ynw61hj7of7ix4dfhijgzfgt 192.168.99.108:2377

#Necesitas estar en un master para lanzar el siguiente comando
eval $(docker-machine env master-1)
docker node ls
#El asterisco te dice desde dónde estás lanzando el comando.

#Lo siguiente es desplegar una aplicación en este cluster
docker service create --name web-nginx \
   -p 8080:8080 \
   --replicas 5 \
   nginx

#Comprueba los servicios que tienes desplegados actualmente
docker service ls

#Para ver más detalle de dónde se han desplegado las replicas
docker service ps web-nginx

#Más información
docker service inspect --pretty web-nginx
docker service inspect web-nginx #Sin el pretty devuelve un JSON

#Escalar el número de réplicas
docker service scale web-nginx=10
docker service ls
docker service ps web-nginx

#Los servicios se despliegan indistintamente en masters y en workers. Para evitarlo, puedes usar constraints



#Visualizador de Docker Swarm
https://github.com/dockersamples/docker-swarm-visualizer

#Lo ejecutamos dentro del cluster como un contenedor más
eval $(docker-machine env master-2)

docker service create \
  --name=viz \
  --publish=9090:8080/tcp \
  --constraint=node.role==manager \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  dockersamples/visualizer

docker service ls
docker service ps viz

#En mi ejemplo se ha desplegado en el master-0 pero puedo acceder desde cualquier nodo
docker-machine ip master-1 #(192.168.99.109:9090) #Esto es así porque a nivel de networking se configura por defecto el modo Ingress

#Modo Ingress vs. Host


# Docker Machine loves Azure
#https://docs.docker.com/machine/drivers/azure/
export AZURE_SUBSCRIPTION_ID=e39a6423-dbba-44c8-aff0-3308926843fc
export AZURE_LOCATION="northeurope"
export AZURE_RESOURCE_GROUP="north-docker"

docker-machine create --driver azure docker-on-azure


# Docker Stacks #


#Deberes:
# 1. Desplegar con Docker Compose una aplicación que conste de un frontal y un backend (buscar ejemplo)
# 2. Crear un cluster con Docker Machine con dos masters y 3 worker nodes en Mac o Windows.
# 3.