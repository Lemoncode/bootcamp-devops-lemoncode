#Deberes:
# 1. Crea una nueva red de tipo bridge/nat llamada lemoncode
docker network create lemoncode
docker network ls
# 2. Crea dos contenedores dentro de la red que acabas de crear, uno de ellos con la imagen nginx
docker run -dit --name ubuntu-container --network lemoncode ubuntu bash
docker run -d --name nginx-container --network lemoncode nginx
# 3. Con cURL y el nombre del contenedor solicita la web que se está ejecutando con Nginx
docker attach ubuntu-container
apt update && apt upgrade && apt -y install curl
curl http://nginx-container
exit