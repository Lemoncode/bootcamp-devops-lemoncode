#https://docs.microsoft.com/en-us/visualstudio/containers/bridge-to-kubernetes?view=vs-2019
#https://docs.microsoft.com/en-us/visualstudio/containers/overview-bridge-to-kubernetes?view=vs-2019
# https://marketplace.visualstudio.com/items?itemName=mindaro.mindaro
#Variables
RESOURCE_GROUP="Bridge-To-Kubernetes"
AKS_NAME="lemoncode-dev"
LOCATION="northeurope"

#Puedes usar Bridge to Kubernetes para redirigir el tráfico entre tu clúster en la nube
#y tu entorno de desarrollo.

#Lo primero que vamos a hacer es crear un clúster
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION

az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_NAME \
    --location $LOCATION \
    --node-count 1 \
    --generate-ssh-keys

#Recuperamos el contexto del cluster
az aks get-credentials -g ${RESOURCE_GROUP} -n ${AKS_NAME}

#Para ver claramente cómo podemos interactuar con el clúster en local, 
#vamos a desplegar en él un MongoDB, el cual es el que utilizará mi web api en la carpeta webapi
kubectl apply -f 04-cloud/00-aks/01-brigde-to-kubernetes/manifests/mongodb.yml
kubectl get po --watch

#Desplegamos la webapi que hace uso del mongodb
kubectl apply -f 04-cloud/00-aks/01-brigde-to-kubernetes/manifests/webapi.yml
kubectl get po,svc

#Instalamos la extensión Bridge to Kubernetes en Visual Studio code instalada.
# Hacemos la configuración para la depuración de la web api (puerto 5001)

#Comprueba el archivo hosts
cat /private/etc/hosts

#Ahora puedo depurar desde mi local mis servicios desplegados en Kubernetes

