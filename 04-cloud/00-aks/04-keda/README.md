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
STORAGE_ACCOUNT_NAME=storage$RANDOM

az storage account create \
--name $STORAGE_ACCOUNT_NAME \
--resource-group $RESOURCE_GROUP \
--location $LOCATION \
--sku Standard_LRS \
--query connectionString \
--output tsv
```

Ahora recupera la cadena de conexión a la cuenta de almacenamiento:

```bash
STORAGE_CONNECTION_STRING=$(az storage account show-connection-string \
--name $STORAGE_ACCOUNT_NAME \
--resource-group $RESOURCE_GROUP \
--output tsv)
```

Una vez creada la cuenta de almacenamiento, vamos a crear una cola de mensajes:

```bash
QUEUE_NAME=queue$RANDOM
az storage queue create \
--name $QUEUE_NAME \
--account-name $STORAGE_ACCOUNT_NAME
```

Con ello, lo único que nos queda es asociar un `ScaledObject` a nuestro deployment de la API. Para ello, vamos a crear un fichero `ScaledObject` con el siguiente contenido:

```bash
kubectl apply -f - <<EOF
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: azure-queue-scaledobject
  namespace: tour-of-heroes
spec:
  scaleTargetRef:
    name: tour-of-heroes-api
  triggers:
  - type: azure-queue
    metadata:
      # Required
      queueName: $QUEUE_NAME
      # Optional, required when pod identity is used
      accountName: $STORAGE_ACCOUNT_NAME
      # Optional: connection OR authenticationRef that defines connection
      connectionFromEnv: STORAGE_CONNECTION_STRING # Default: AzureWebJobsStorage. Reference to a connection string in deployment
      # or authenticationRef as defined below
      #
      # Optional
      queueLength: "5" # default 5
  minReplicaCount: 0 # default 0
  maxReplicaCount: 33 # default 100
EOF
```

Puedes comprobar que el mismo se ha creado sin problemas con este comando:

```bash
kubectl get scaledobject -n tour-of-heroes
```

Para comprobar si hay algún error en el ScaledObject, puedes ejecutar el siguiente comando:

```bash
kubectl describe scaledobject/azure-queue-scaledobject -n tour-of-heroes
```

Para que el ScaledObject funcione debemos modificar el deployment de la API para que tenga la variable de entorno que almacena la cadena de conexión a la cuenta de almacenamiento:

```bash
kubectl set env deployment/tour-of-heroes-api \
--namespace tour-of-heroes \
STORAGE_CONNECTION_STRING=$STORAGE_CONNECTION_STRING
```

Comprueba también que la variable de entorno forma parte de tu deployment:

```bash
kubectl describe deployment/tour-of-heroes-api \
--namespace tour-of-heroes
```

Ahora, **en un nuevo terminal**, vigila los pods de la API en un terminal:

```bash
kubectl get pods -n tour-of-heroes -w
```

Y en otro vamos a insertar en bucle unos cuantos mensajes en la cola de mensajes:

```bash
while true; do
    az storage message put \
    --queue-name $QUEUE_NAME \
    --content "Hello world" \
    --account-name $STORAGE_ACCOUNT_NAME
done
```
Si todo se ha configurado correctamente, verás como el número de pods de la API se incrementa en función del número de mensajes que se van insertando en la cola de mensajes.

Tadaaa 🎉! Ya tienes tu API escalando automáticamente en función de eventos externos.

Ahora elimina los mensajes de la cola de mensajes:

```bash
az storage message clear \
--queue-name $QUEUE_NAME \
--account-name $STORAGE_ACCOUNT_NAME \
--connection-string $STORAGE_CONNECTION_STRING
```

Y comprueba como los pods de la API se van eliminando.