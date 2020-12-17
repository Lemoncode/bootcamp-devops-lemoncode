# https://www.returngis.net/2020/06/escalado-rapido-y-puntual-de-tus-pods-con-virtual-kubelet/


#Crear clúster de prueba
# Variables
RESOURCE_GROUP="Kubelet-Demo"
AKS_NAME="returngis"
LOCATION="northeurope"

# Create an AKs cluster
az group create -n $RESOURCE_GROUP -l $LOCATION
az aks create --resource-group $RESOURCE_GROUP --name $AKS_NAME --node-count 1 --generate-ssh-keys

# Get AKS context
az aks get-credentials -n $AKS_NAME -g $RESOURCE_GROUP

kubectl get pods -o wide

#Desplegar Virtual Kubelet con el conector para Azure Container Instances
#Install Helm 2
brew install helm@2
brew link --force --overwrite helm@2

kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller-role-binding --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller --upgrade

#Install ACI Connector for Kubelet
az aks install-connector --resource-group $RESOURCE_GROUP --name $AKS_NAME --connector-name aciconnector

kubectl get nodes

kubectl describe node virtual-kubelet-aciconnector-linux-northeurope

kubectl get pods -o wide