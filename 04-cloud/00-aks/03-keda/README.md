# Autoescalar los pods con KEDA

[KEDA](https://keda.sh/) es un proyecto de código abierto que permite escalar automáticamente los pods de Kubernetes en función de eventos externos. Estos eventos pueden ser desde colas de mensajes, sistemas de mensajería, bases de datos, etc.

# Habilitar KEDA en AKS

A día de hoy es muy fácil habilitar KEDA en AKS. Simplemente debes ejecutar el siguiente comando:

```bash
az aks update -n $AKS_NAME \
-g $RESOURCE_GROUP \
--enable-keda
```
Para comprobar que KEDA está habilitado, ejecuta el siguiente comando:

```bash
kubectl get pods -n kube-system | grep keda
```

Y voilà! Ya tienes KEDA habilitado en tu cluster de AKS. Ahora podríamos crear un nuevo deployment y escalarlo automáticamente en función de eventos externos.

Para este ejemplo lo que vamos a hacer es escalar la API de nuestro Tour of heroes en función a una cola de mensajes de Azure Storage. Así que lo siguiente que necesitamos es crear una cuenta de almacenamiento en Azure:

```bash
STORAGE_ACCOUNT_NAME=storage$(uuidgen | cut -d '-' -f5 | tr '[A-Z]' '[a-z]')

STORAGE_CONNECTION_STRING=$(az storage account create \
--name $STORAGE_ACCOUNT_NAME \
--resource-group $RESOURCE_GROUP \
--location $LOCATION \
--sku Standard_LRS \
--query connectionString \
--output tsv)
```

Una vez creada la cuenta de almacenamiento, vamos a crear una cola de mensajes:

```bash
QUEUE_NAME=queue$(uuidgen | cut -d '-' -f5 | tr '[A-Z]' '[a-z]')
az storage queue create \
--name $QUEUE_NAME \
--account-name $STORAGE_ACCOUNT_NAME
```

Con ello, lo único que nos queda es asociar un `ScaledObject` a nuestro deployment de la API. Para ello, vamos a crear un fichero `ScaledObject` con el siguiente contenido:

```yaml
apiVersion: keda.k8s.io/v1alpha1
kind: ScaledObject
metadata:
  name: tour-of-heroes
  namespace: default
spec:
    scaleTargetRef:
        deploymentName: tour-of-heroes
    pollingInterval: 5
    cooldownPeriod:  30
    minReplicaCount: 1
    maxReplicaCount: 10
    triggers:
    - type: azure-queue
        metadata:
        queueName: $QUEUE_NAME
        connectionFromEnv: STORAGE_CONNECTION_STRING
        queueLength: "5"
```

Para que el ScaledObject funcione debemos modificar el deployment de la API para que tenga la variable de entorno que almacena la cadena de conexión a la cuenta de almacenamiento:

```bash
kubectl set env deployment/tour-of-heroes-api \
--namespace tour-of-heroes \
STORAGE_CONNECTION_STRING=$STORAGE_CONNECTION_STRING
```



