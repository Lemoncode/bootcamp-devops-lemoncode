#https://docs.microsoft.com/es-es/azure/aks/virtual-nodes-cli
#Los nodos virtuales permiten la comunicación de red entre los pods que se ejecutan en Azure Container Instances (ACI) 
#y el clúster de AKS. Para proporcionar esta comunicación, se crea una subred de red virtual y se asignan permisos delegados. 
#Los nodos virtuales solo funcionan con clústeres de AKS creados mediante redes avanzadas (Azure CNI). 
#De manera predeterminada, los clústeres de AKS se crean con redes básicas (kubenet). 

# Variables
RESOURCE_GROUP="Virtual-Kubelet"
AKS_NAME="lemoncode-kubelet"
AKS_VNET="aks-vnet"
AKS_SUBNET="aks-subnet"
AKS_VKUBELET_SUBNET="aks-virtual-subnet"
LOCATION="northeurope"

#Antes de hacer uso de los virtual kubelets es necesario tener registrado el proveedor Microsoft.ContainerInstance
az provider list --query "[?contains(namespace,'Microsoft.ContainerInstance')]" -o table
#Si no lo está puedes hacer uso de este comando
az provider register --namespace Microsoft.ContainerInstance

#Crear un grupo de recursos
az group create -n $RESOURCE_GROUP -l $LOCATION

#Crear una red privada virtual en Azure
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_VNET \
    --address-prefixes 192.168.0.0/16 \
    --subnet-name $AKS_SUBNET \
    --subnet-prefix 192.168.1.0/24

#Ahora creamos una subred adicional para los nodos virtuales
az network vnet subnet create \
    --resource-group $RESOURCE_GROUP \
    --vnet-name $AKS_VNET \
    --name $AKS_VKUBELET_SUBNET \
    --address-prefixes 192.168.2.0/24

#Crear un service principal
az ad sp create-for-rbac --name kubelet-demo > auth.json
CLIENT_ID=$(jq -r '.appId' auth.json)
PASSWORD=$(jq -r '.password' auth.json)

#Asignamos permisos a la red virtual para que el cluster pueda gestionarla
VNET_ID=$(az network vnet show --resource-group $RESOURCE_GROUP --name $AKS_VNET --query id -o tsv)
az role assignment create --assignee $CLIENT_ID --scope $VNET_ID --role Contributor

#Obtenemos el ID de la subnet donde va a ir el cluster de AKS
SUBNET_ID=$(az network vnet subnet show --resource-group $RESOURCE_GROUP --vnet-name $AKS_VNET --name $AKS_SUBNET --query id -o tsv)

#Creamos el cluster
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_NAME \
    --node-count 1 \
    --network-plugin azure \
    --vnet-subnet-id $SUBNET_ID \
    --service-principal $CLIENT_ID \
    --client-secret $PASSWORD

# Recuperar el contexto para este clúster
az aks get-credentials -n $AKS_NAME -g $RESOURCE_GROUP

#Desplegamos una aplicación de ejemplo
cd 04-cloud/00-aks/03-virtual-kubelet
kubectl apply -f manifests/nginx-deployment.yml

kubectl get deploy
kubectl get pods -o wide --watch
kubectl describe pod NOMBRE_DE_POD_PENDIENTE
#Algunos pods se quedarán pendientes porque no hay espacio suficiente para ellos.

#Habilita el complemento para los nodos virtuales
az aks enable-addons \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_NAME \
    --addons virtual-node \
    --subnet-name $AKS_VKUBELET_SUBNET

#Comprobamos que ahora tenemos un nodo virtual llamado virtual-node-aci-linux
kubectl get nodes
kubectl get pods -o wide

#Si escalamos más nuestro despliegue veremos que escala mucho más rápido que con el autoscaler del cluster
kubectl scale --replicas=5 deployment/nginx-deployment
kubectl get pods -o wide --watch

#Si eliminamos el grupo de recursos eliminaremos el clúster
az group delete -n ${RESOURCE_GROUP} --yes --no-wait