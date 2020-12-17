#Variables
RESOURCE_GROUP="AKS-Demo"
AKS_NAME="gisaks"

#Enable Azure Dev Spaces
az aks use-dev-spaces -g ${RESOURCE_GROUP} -n ${AKS_NAME}

# https://www.returngis.net/2020/05/depurar-aplicaciones-en-kubernetes-con-azure-dev-spaces-y-visual-studio-code/