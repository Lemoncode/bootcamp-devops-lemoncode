#Variables
RESOURCE_GROUP="AKS-Loves-AzureAD"
AKS_NAME="lemoncode-azuread"
LOCATION="northeurope"

# Crear un grupo de recursos
az group create --name $RESOURCE_GROUP --location $LOCATION

#Crear un cluster integrado con Azure AD
az aks create -g $RESOURCE_GROUP -n $AKS_NAME --enable-aad --node-count 1

#Recuperar las credenciales de administrador para acceder al cluster
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --admin

#Comprueba que puedes acceder a los recursos del cluster
kubectl get nodes

#Para que un usuario pueda interactuar con el clúster debemos asignar el Id del grupo de Azure AD al que pertenece al role
#Estos son los ids de todos los grupos de mi directorio activo:
az ad group list -o table
#Almaceno el id del grupo llamado Stark
GROUP_ID=$(az ad group show --group Stark --query objectId -o tsv)

#Recupero también el ID del clúster de AKS
AKS_ID=$(az aks show -g ${RESOURCE_GROUP} -n ${AKS_NAME} --query id -o tsv)

#Asigno el grupo al rol "Azure Kubernetes Service Cluster User Role" en este cluster, porque no todos los grupos de Azure AD tienen por qué tener acceso a mi clúster
az role assignment create \
    --assignee $GROUP_ID \
    --role "Azure Kubernetes Service Cluster User Role" \
    --scope $AKS_ID

#Hago lo mismo con los Lanisters
GROUP_TWO_ID=$(az ad group show --group Lannister --query objectId -o tsv)

#De nuevo, asigno el grupo al rol "Azure Kubernetes Service Cluster User Role" en este cluster, porque no todos los grupos de Azure AD tienen por qué tener acceso a mi clúster
az role assignment create \
    --assignee $GROUP_TWO_ID \
    --role "Azure Kubernetes Service Cluster User Role" \
    --scope $AKS_ID

#Si lo ves desde el portal tendríamos que tener estos dos grupos asignados a este rol en el cluster.

#Ahora vamos a crear dos namespaces como admin
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --admin

#Creamos el namespace, el role y el role binding (asociación) con el grupo Stack
kubectl apply -f 04-cloud/00-aks/05-azure-active-directory/manifests/the-north-remembers.yaml

#Creamos el namespace, el role y el role binding (asociación) con el grupo Lanister
kubectl apply -f 04-cloud/00-aks/05-azure-active-directory/manifests/kings-landing.yaml

#Ahora vamos a probar que los accesos funcionan correctamente. Lo primero que tenemos que hacer ese resetear el archivo
#kubeconfig, ya que ahora lo tenemos con credenciales de admin, y este pasa por alto la autenticación con Azure AD. Sin el 
#parámetro --admin el contexto de usuario normal es el que aplica y requerirá que todas las peticiones pasen por Azure AD.
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing

#Vamos a probar the north remembers creando un pod dentro de este namespace
#Lanzar este comando te pedirá autenticación
kubectl run --generator=run-pod/v1 nginx-north --image=nginx --namespace the-north-remembers
kubectl get po -n the-north-remembers

#Si intentamos acceder al namespace de los Lanister o el default nos dará error
kubectl get po -n kings-landing
kubectl get po

#Ahora vamos a probar lo mismo con los Lanister. 
#Reseteamos las credenciales de nuevo
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing

#Intentamos la misma operación pero en el namespace de los Lanister
kubectl run --generator=run-pod/v1 nginx-kings-landing --image=nginx --namespace kings-landing
#Si intentamos entrar en The North Remembers da un error
kubectl get po -n the-north-remembers

#Si eliminamos el grupo de recursos eliminaremos el clúster
az group delete -n ${RESOURCE_GROUP} --yes --no-wait