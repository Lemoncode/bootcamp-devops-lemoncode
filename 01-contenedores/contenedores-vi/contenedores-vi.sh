# Parte 6: Docker Compose #
cd 01-contenedores/contenedores-vi

#Imagínate un escenario donde quieres desplegar un blog con Wordpress. 
#Este, necesita de una base de datos MySQL para funcionar, por lo que antes de desplegar esta aplicación necesitas una base de datos de este tipo
#Si quisieramos hacerlo de forma manual, sería de la siguiente manera:

#1. Creo la red donde ambos contenedores van poder comunicarse
docker network create wordpress-network
#2. Creo la base de datos MySQL, conectada a la red anterior, con un volumen que guarde la información de /var/lib/mysql.
docker run -it --name mysqldb --network wordpress-network --rm --mount source=mysql_data,target=/var/lib/mysql \
 -e MYSQL_ROOT_PASSWORD=somewordpress -e MYSQL_DATABASE=wpdb -e MYSQL_USER=wp_user -e MYSQL_PASSWORD=wp_pwd \
  mysql:5.7

#2.1 Esto habrá hecho que se genere un volumen nuevo llamado mysql_data
docker volume ls

#3. Ahora que ya tenemos la base de datos, el siguiente paso sería generar el contenedor de Wordpress
# dentro de la misma red y apuntando al contenedor de MySQL
docker run -it --name wordpress --network wordpress-network --rm \
-e WORDPRESS_DB_HOST=mysqldb:3306 -e WORDPRESS_DB_USER=wp_user -e WORDPRESS_DB_PASSWORD=wp_pwd -e WORDPRESS_DB_NAME=wpdb \
-p 8000:80 wordpress:latest

#Si quisiera eliminar todo el proceso debería de hacer
docker rm -f wordpress mysqldb
docker network rm wordpress-network
docker volume rm mysql_data

#Y volver a relanzar todo si quisiera volver a crearlo

#Lo mismo pero con Docker Compose

cat docker-compose.yml

docker-compose up & #con el & al final te deja utilizar el terminal, además de ver la salida

#Parar y eliminar
docker-compose down

#Otro de los escenarios que te puedes encontrar es que quieras que cada vez que haces un compose up
#se genere la imagen de tu app
docker-compose -f docker-compose-app.yml up --build
docker-compose -f docker-compose-app.yml ps
docker-compose -f docker-compose-app.yml down

#Ejecutar en segundo plano tu aplicación con Docker Compose
docker-compose up -d 

#Como siempre, puedes ver todos los contenedores con docker ps
docker ps

#Con docker compose puedes ver todas las aplicaciones que se están ejecutando
docker-compose ps

#Añadir un nombre a la aplicación
docker-compose --project-name my_wordpress up -d

#Si quisieramos reiniciar la aplicación
docker-compose -p my_wordpress restart

#Parar las aplicaciones sin eliminar los contenedores
docker-compose -p my_wordpress stop
docker-compose -p my_wordpress ps

#Si quisiera parar y eliminar, todo a la vez
docker-compose -p my_wordpress down
docker-compose -p my_wordpress ps

#Si solo quisiera eliminar podría usar
docker-compose -p my_wordpress rm -y

# Docker Swarm #

#Antes de trabajar con el orquestador Docker Swarm es necesario crear el cluster a través del siguiente comando:
docker swarm init
#El primer nodo que lance este comando se convertirá en master. El terminal devolverá el comando a ejecutar para unir workers, y masters, al cluster
#Cuando trabajas con Windows y Mac se están utilizando virtualizaciones para Docker por lo que no es posible probar este escenario. es fácil verlo porque el comando anterior devuelve una IP que no es la de tu máquina local.
#Para salirse del cluster:
docker swarm leave --force

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

#Linux
ssh gis@137.135.216.143
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
sudo apt-get update
sudo apt-get install virtualbox -y

base=https://github.com/docker/machine/releases/download/v0.16.0 &&
  curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
  sudo mv /tmp/docker-machine /usr/local/bin/docker-machine &&
  chmod +x /usr/local/bin/docker-machine


#Comprueba que la instalación se ha hecho correctamente
docker-machine version

#Cómo crear una máquina con Docker Engine con docker-machine
#Linux
sudo docker-machine create master-0
sudo docker-machine create master-0 --virtualbox-no-vtx-check
vboxmanage list vms
#Virtual Box
docker-machine create --driver virtualbox master-0
#Hyper-V
docker-machine create --driver hyperv master-0

#Listar las máquinas que están ejecutándose
docker-machine ls

#Para conocer el estado de una máquina
docker-machine status master-0

#Conectar tu Docker Client a master-0
docker-machine env master-0 #Mac
docker-machine env --shell powershell master-0 #Windows
eval $(docker-machine env master-0) #Mac
# docker-machine url master-0
docker info #Comprueba que el nombre de la máquina sea el mismo que elegiste en la creación con docker-machine
docker ps
#Comprueba que las variables de entorno apuntan a la máquina creada
env | grep DOCKER #Mac
Get-ChildItem Env: | Where-Object { $_.Name -Match "DOCKER"} #PowerShell

#Ejecuta un contenedor en la máquina que tienes como contexto
docker run busybox echo hello world
docker ps -a

#Ejecutar un Nginx 
docker run -d -p 8000:80 nginx

#Recuperar la IP de uno de los nodos
docker-machine ip master-0

#Hacer una petición al servidor web
curl $(docker-machine ip master-0):8000

#Parar una máquina
docker-machine stop master-0

#Iniciar una máquina
docker-machine start master-0

#Para hacer que el terminal vuelva a apuntar a Docker Desktop
docker-machine env -u --shell poweshell #Windows
docker-machine env -u #Mac
eval $(docker-machine env -u)
env | grep DOCKER #Mac
Get-ChildItem Env: | Where-Object { $_.Name -Match "DOCKER"} #PowerShell

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

#En el master podemos lanzar este comando para inspeccionarse a si mismo
docker node inspect self --pretty

#o bien a otro nodo
docker node inspect worker-0 --pretty

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
docker service create \
    --name nginx-workers-only \
    --constraint node.role==worker \
    nginx


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
#Ingress: da igual a qué nodo pregunte, aunque no tenga réplica me va a contestar bien
docker service create --name my_web --replicas 2 --publish published=8080,target=80 nginx
#Host: solo me contestará bien si tiene una réplica
docker service create --name my_web --replicas 2 --publish published=8080,target=80,mode=host nginx

# Docker Machine loves Azure
#https://docs.docker.com/machine/drivers/azure/
export AZURE_SUBSCRIPTION_ID=e39a6423-dbba-44c8-aff0-3308926843fc
export AZURE_LOCATION="northeurope"
export AZURE_RESOURCE_GROUP="north-docker"

docker-machine create --driver azure docker-on-azure

# Docker Stacks #

#Con Docker Stacks podemos utilizar archivos de la misma forma que hacíamos con Docker Compose pero orientados a Docker Swarm.



#Deberes:
# 1. Desplegar con Docker Compose una aplicación que conste de un frontal y un backend (buscar ejemplo)
# 2. Crear un cluster con Docker Machine con dos masters y 3 worker nodes en Mac o Windows.
# 3. Despliega Wordpress dentro del clúster