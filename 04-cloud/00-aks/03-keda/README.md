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
````

Y voilà! Ya tienes KEDA habilitado en tu cluster de AKS.

