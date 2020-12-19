#Para entender KEDA primero necesitas saber cómo autoescalan los pods dentro de un clúster

### Ejemplo de autoescalado sin KEDA
#Autoescalar tus aplicaciones en Kubernetes: https://www.returngis.net/2020/05/autoescalar-tus-aplicaciones-en-kubernetes/
kubectl apply -f 04-cloud/00-aks/04-keda/manifests/autoscale-with-hpa.yml
kubectl autoscale deployment web --cpu-percent=30 --min=1 --max=5
kubectl get hpa --watch

ab -n 50000 -c 200 http://51.104.177.27/

kubectl describe hpa web

#KEDA
# https://www.returngis.net/2020/06/autoescalar-tus-aplicaciones-en-kubernetes-con-keda/

#Variables
RESOURCE_GROUP="KEDA"
AKS_NAME="lemoncode-keda"

#Instalar Helm
brew install helm

#Añadir el repo de KEDA
helm repo add kedacore https://kedacore.github.io/charts
helm repo update

#Creamos el grupo de recursos
az group create -n ${RESOURCE_GROUP} -l ${LOCATION}

#Creamos un cluster
az aks create -g ${RESOURCE_GROUP} -n ${AKS_NAME} \
--node-count 1 --generate-ssh-keys

#Configuramos kubectl para comunicarnos con nuestro nuevo clúster
az aks get-credentials -g ${RESOURCE_GROUP} -n ${AKS_NAME}

#Creamos un namespace llamado keda
kubectl create namespace keda

#Instalamos los componentes dentro del namespace de KEDA
helm install keda kedacore/keda --namespace keda

kubectl get pods -n keda --watch

#Crear un ScaledObject para el deployment
#Vamos a basar el escalado en los mensajes que haya en una cola de mensajes.
#Para ello nos apoyamos en un servicio llamado Azure Storage

#Creamos una cuenta de almacenamiento
STORAGE_NAME="boxoftasks"
az storage account create --name $STORAGE_NAME --resource-group $RESOURCE_GROUP
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_NAME --query "[0].value" --output tsv)

#Creamos una cola dentro de la cuenta de almacenamiento
az storage queue create --name "tasks" \
--account-name $STORAGE_NAME \
--account-key $ACCOUNT_KEY

#Recuperamos la cadena de conexión
CONNECTION_STRING=$(az storage account show-connection-string --name $STORAGE_NAME --resource-group $RESOURCE_GROUP -o tsv)

#La guardamos en un secret de Kubernetes
kubectl create secret generic storage-secret --from-literal=connection-string=$CONNECTION_STRING

kubectl apply -f 04-cloud/00-aks/04-keda/manifests/web-deployment.yml
kubectl get pods --watch

#Ahora creamos un objeto del tipo ScaledObject, propios de KEDA
kubectl apply -f 04-cloud/00-aks/04-keda/manifests/scaledObject.yml
kubectl get scaledobject
kubectl get hpa -w

#Para probar esto añadimos un montón de mensajes en la cola de mensajería, para que escale el despliegue
while true; do az storage message put --content "Hello from KEDA" --queue-name "tasks" --account-name $STORAGE_NAME --account-key $ACCOUNT_KEY; done

#Ahora probamos lo mismo pero para que desescale
az storage message clear --queue-name "tasks" --account-name $STORAGE_NAME --account-key $ACCOUNT_KEY

#En esta página puedes ver todos los scaled object disponibles: https://keda.sh/docs/2.0/scalers/