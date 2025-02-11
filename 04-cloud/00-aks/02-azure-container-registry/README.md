# Azure Container Registry

Es común que cuando trabajamos con Azure Kubernetes Services también utilicemos Azure Container Registry para almacenar nuestras imágenes de contenedores. Este ofrece un montón de ventajas no solo relacionadas con AKS sino en general.

## Crear un Azure Container Registry

Lo primero que vamos a hacer es crearnos un recurso de este tipo, en el mismo grupo de recursos donde tenemos nuestro clúster:

```bash
RESOURCE_GROUP="bootcamp-lemoncode"
ACR_NAME="lemoncodeacr$RANDOM"
LOCATION="spaincentral"

az acr create -n ${ACR_NAME} -g ${RESOURCE_GROUP} --sku Basic --location ${LOCATION}
```

Una vez que ya lo tienes, en este se pueden o bien generar imágenes en local y luego publicarlas:

```bash
az acr login -n ${ACR_NAME}
docker build -t ${ACR_NAME}.azurecr.io/hello-world:v1 04-cloud/00-aks/02-azure-container-registry
docker push ${ACR_NAME}.azurecr.io/hello-world:v1
```

O bien, puedes hacer uso de la funcionalidad de `acr build` que te permite hacer el build y el push en un solo paso:

```bash
az acr build -r ${ACR_NAME} -t ${ACR_NAME}.azurecr.io/hello-lemoncode:{{.Run.ID}} 04-cloud/00-aks/02-azure-container-registry
```
Esto además significa que no necesitas tener Docker instalado en tu máquina, ya que el proceso de build se hace en la nube. Y lo chulo de esto es que podemos usar diferentes plataformas de build como por ejemplo Windows, Linux o ARM.

```bash
az acr build -r ${ACR_NAME} -t ${ACR_NAME}.azurecr.io/hello-lemoncode:linux-arm 04-cloud/00-aks/02-azure-container-registry --platform linux/arm/v7
```

## Usar el Azure Container Registry en AKS

Lo chulo de todo esto es que AKS ya viene preparado para trabajar con ACR, por lo que no necesitas hacer nada especial para que funcione. Lo único que tienes que hacer es decirle a tu clúster que use tu ACR:

```bash
AKS_NAME="lemoncode-cluster"

az aks update -n ${AKS_NAME} -g ${RESOURCE_GROUP} --attach-acr ${ACR_NAME}
```

Y con esto ya puedes hacer uso de tus imágenes almacenadas en tu ACR en tu clúster de AKS. Para probarlo, puedes desplegar un pod que haga uso de una de estas imágenes:

```bash
az aks get-credentials -g ${RESOURCE_GROUP} -n ${AKS_NAME} --overwrite-existing

LAST_TAG=$(az acr repository show-tags -n ${ACR_NAME} --repository hello-world --orderby time_desc --top 1 --output tsv)

echo "La última imagen de hello-world es ${LAST_TAG}"

kubectl run hello-lemoncode --image=${ACR_NAME}.azurecr.io/hello-world:${LAST_TAG}

kubectl get pods -w
```