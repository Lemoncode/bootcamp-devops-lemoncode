# https://www.returngis.net/2019/04/azure-kubernetes-service-tu-cluster-manejado-en-la-nube/

#Antes de empezar a interactuar con nuestro clúster en AKS necesitamos instalar Azure CLI
#Install the Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
brew install azure-cli

#También podemos crear un contenedor con Azure CLI. Así no tenemos que instalarlo en nuestro local ;-)
docker run -it --rm microsoft/azure-cli sh

#Iniciamos sesión en nuestra cuenta de Azure
az login

#Creamos un grupo de recursos en una ubicación concreta
RESOURCE_GROUP="Mi-Primer-AKS"
LOCATION="northeurope"

az group create -n ${RESOURCE_GROUP} -l ${LOCATION}

#Creamos el clúster de AKS
AKS_NAME="lemoncode-aks"

#https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az_aks_create
az aks create -g ${RESOURCE_GROUP} -n ${AKS_NAME} \
--node-count 1 --generate-ssh-keys

#Instalamos kubectl en local si no lo tenemos. En este caso en el contenedor con Azure CLI
az aks install-cli

#Configuramos kubectl para comunicarnos con nuestro nuevo clúster
az aks get-credentials -g ${RESOURCE_GROUP} -n ${AKS_NAME}

#Recuperamos los nodos de nuestro clúster (en este ejemplo solo deberíamos de tener 1)
kubectl get nodes

#Recuperamos todos los servicios desplegados en nuestro clúster
kubectl get services --all-namespaces

#Escalar el número de nodos en el clúster
az aks scale -g ${RESOURCE_GROUP} -n ${AKS_NAME} --node-count 3

#Ahora deberíamos tener 3 nodos en lugar de 1
kubectl get nodes

#Si eliminamos el grupo de recursos eliminaremos el clúster
az group delete -n ${RESOURCE_GROUP}
