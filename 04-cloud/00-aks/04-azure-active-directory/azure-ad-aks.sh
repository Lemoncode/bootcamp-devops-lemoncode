#Variables
RESOURCE_GROUP="AKS-Loves-AzureAD"
AKS_NAME="lemoncode-azuread"
LOCATION="northeurope"

# Crear un grupo de recursos
az group create --name $RESOURCE_GROUP --location $LOCATION

#Crear un cluster integrado con Azure AD
az aks create -g $RESOURCE_GROUP -n $AKS_NAME --enable-aad 

#Recuperar las credenciales de administrador para acceder al cluster
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --admin

#Comprueba que puedes acceder a los recursos del cluster
kubectl get nodes

### Escenario 1: Soy Gisela y quiero tener permisos de administrador dentro del cluster
kubectl apply -f 04-cloud/00-aks/04-azure-active-directory/manifests/cluster-role-binding.yaml
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing

#Ahora pruebo con un usario que no tiene credenciales de admin total
kubectl get pods #ESTO NO VA

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

# Namespace para los Stark #

#Ahora vamos a crear dos namespaces como admin
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --admin

#Creamos el role
kubectl apply -f 04-cloud/00-aks/04-azure-active-directory/manifests/role-the-north-remembers-ns.yaml
#Hacemos la asociación del role a un grupo, en este caso los Stark
kubectl apply -f 04-cloud/00-aks/04-azure-active-directory/manifests/ns-the-north-remembers-and-role-binding.yml

# Namespace para los Lanister #


