# Variables
RESOURCE_GROUP="Cluster-Autoscaler"
AKS_NAME="lemoncode-autoscaler"
LOCATION="northeurope"

#Crear grupo de recursos
az group create -n ${RESOURCE_GROUP} -l ${LOCATION}

#Crear cluster de AKS
az aks create -g ${RESOURCE_GROUP} \
-n ${AKS_NAME} \
--node-count 1 \
--generate-ssh-keys

# Recuperar el contexto para este clúster
az aks get-credentials -n $AKS_NAME -g $RESOURCE_GROUP

#Desplegar una aplicación de ejemplo con más pods de los que caben en el clúster
kubectl apply -f manifests/nginx-deployment.yml

#Uno se ejecutará pero el resto quedarán pendientes, porque no hay CPU suficiente para todos.
kubectl get pods
kubectl describe pods

#Escalado manual de nodos
# az aks scale -g $RESOURCE_GROUP -n $AKS_NAME --node-count 3

#Habilitar autoscaler en el cluster
az aks update \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --enable-cluster-autoscaler \
  --min-count 1 \
  --max-count 5

#Mientras esto se materializa puedes ver en el portal de Azure que el virtual machine scaleset está aumentando
#el número de instancias. Este proceso puede llevar varios minutos ya que tiene que dar de alta las VMs

#Si comprobamos pasados unos minutos verás que los pods han sido alocados en nuevos nodos
kubectl get po -o wide --watch

#Configurar el perfil del autoescalado: https://docs.microsoft.com/es-es/azure/aks/cluster-autoscaler#using-the-autoscaler-profile

#Si eliminamos el grupo de recursos eliminaremos el clúster
az group delete -n ${RESOURCE_GROUP} --yes --no-wait