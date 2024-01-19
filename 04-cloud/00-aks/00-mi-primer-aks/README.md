## Prerequisitos

Para poder ejecutar los siguientes comando necesitas tener instalado Azure CLI como se comenta en el [README](../README.md) principal.

Una vez lo tengas, utiliza estas variables de entorno para configurar las tuyas propias si fuera necesario:

```bash
RESOURCE_GROUP="aks-demo"
AKS_NAME="lemoncode-cluster"
LOCATION="uksouth"
```

o si estás en Windows:

```pwsh
$RESOURCE_GROUP="aks-demo"
$AKS_NAME="lemoncode-cluster"
$LOCATION="uksouth"
```

Con estas estamos diciendo cuál sería el nombre del grupo de recursos donde voy a almacenar mi nuevo clúster de Kubernetes, el nombre que le voy a dar al mismo, así como la localización donde se desplegará este. Con estas ya puedo crear primeramente el grupo de recursos:

```bash
az group create -n ${RESOURCE_GROUP} -l ${LOCATION}
```

Ahora que ya tienes un sitio donde guardar recursos, puedes crear tu clúster de Kubernetes en él:

```bash
az aks create -g ${RESOURCE_GROUP} \
-n ${AKS_NAME} \
--node-count 1 \
--generate-ssh-keys
```

Como puedes ver, crear un clúster de AKS es extremadamente sencillo. Obviamente se pueden añadir más opciones durante su creación, pero oye, para ser tu primer clúster es más que suficiente 😉

Una vez que finalice la creación lo siguiente que necesitas es instalar `kubectl` si no lo tienes todavía. Azure CLI también puede ayudarte en esta tarea usando este comando:

```bash
az aks install-cli
```
Una vez finalice podrás recuperar el contexto para poder interactuar con este clúster:

```bash
az aks get-credentials -g ${RESOURCE_GROUP} -n ${AKS_NAME}
```

Para comprobar que puedes conectarte al mismo puedes hacerlo a partir de este momento con `kubectl` de la forma habitual:

```bash
kubectl get nodes
```

¡Hurra 🎉! Ya tienes un clúster totalmente funcional en el que desplegar tus contenedores. Para esta clase vamos a utilizar mi Tour Of Heroes para ver qué pinta tiene en este tipo de entornos. 

Todos los manifiestos que necesitas para el mismo puedes encontrarlos en la carpeta [manifests](manifests/) dentro de esta misma unidad. Para poder aplicar todos los archivos del tirón basta con ejecutar este comando:

```bash
kubectl apply -f manifests/ --recursive
``````