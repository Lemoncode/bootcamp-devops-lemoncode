# https://www.returngis.net/2019/04/azure-kubernetes-service-tu-cluster-manejado-en-la-nube/
#Create an azure-cli container
docker run -it --rm microsoft/azure-cli sh

#Login
az login

#Select your subscription account
az account set -s "Microsoft Azure Internal Consumption"

#Create a resource group
RESOURCE_GROUP="AKS-Demo"
LOCATION="northeurope"

az group create -n ${RESOURCE_GROUP} -l ${LOCATION}

#Create a cluster
AKS_NAME="gisaks"

az aks create -g ${RESOURCE_GROUP} -n ${AKS_NAME} \
--node-count 1 --generate-ssh-keys

#Install kubectl if you don't have it
az aks install-cli

#configure kubectl to comunicate with out AKS cluster
az aks get-credentials -g ${RESOURCE_GROUP} -n ${AKS_NAME}

#Check kubectl version
kubectl version --short

kubectl get nodes

kubectl get services --all-namespaces

#Access Kubernetes Dashboard
az aks browse -g ${RESOURCE_GROUP} -n ${AKS_NAME}

#Giving permissions
kubectl create clusterrolebinding kubernetes-dashboard -n kube-system --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard

#Scale cluster
az aks scale -g ${RESOURCE_GROUP} -n ${AKS_NAME} --node-count 3

#delete the resource group and the cluster
az group delete -n ${RESOURCE_GROUP}
