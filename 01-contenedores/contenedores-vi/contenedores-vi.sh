# Parte 6: Docker Compose #
docker-compose up


# Docker Swarm #

#Antes de trabajar con el orquestador Docker Swarm es necesario crear el cluster a través del siguiente comando:
docker swarm init
#El primer nodo que lance este comando se convertirá en master. El terminal devolverá el comando a ejecutar para unir workers, y masters, al cluster
#Cuando trabajas con Windows y Mac se están utilizando virtualizaciones para Docker por lo que no es posible probar este escenario. es fácil verlo porque el comando anterior devuelve una IP que no es la de tu máquina local.

#Docker Machine
https://docs.docker.com/machine/overview/



#Para estos ejemplos voy a montar unas máquinas con Docker en Azure para hacer las pruebas con Swarm.
#https://github.com/Azure/azure-quickstart-templates/tree/master/docker-swarm-cluster

#Generar SSH Public Key
ssh-keygen -o


#El mismo ejemplo pero en local con Virtual Box


#Lo mismo pero con la web Play with Docker: https://training.play-with-docker.com/swarm-mode-intro/





#Visualizador de Docker Swarm
https://github.com/dockersamples/docker-swarm-visualizer




# Docker Stacks #


#Deberes:
# 1. 
# 2.
# 3.