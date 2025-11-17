# Cómo saber cuánto cuestan tus Pods en AKS

Microsoft Azure nos permite saber cuánto nos cuesta cada uno de los pods que tenemos en nuestro cluster de Kubernetes. Esto es muy útil para saber qué pods son los que más recursos consumen y, por tanto, los que más nos cuestan.

Para habilitar esta funcionalidad solo necesitas actualizar tu cluster de AKS con el parámetro `--enable-cost-analysis`. Para ello, ejecuta el siguiente comando:

```bash
az aks update -n $AKS_NAME \
-g $RESOURCE_GROUP \
--tier standard \
--enable-cost-analysis
```
Con esta característica habilitada, podrás ver el coste de cada uno de los pods de tu cluster de Kubernetes. [Aquí tienes la documentación donde se explica cómo](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/view-kubernetes-costs). Simplemente acude al portal de Azure > Busca Cost Management y en el combo selecciona **Kubernetes clusters**. Puedes obtener una vista por namespace y dentro de este ver el coste de cada uno de los pods.

## Cómo saber si esta funcionalidad está habilitada

Para saber si esta funcionalidad está habilitada en tu cluster de AKS, puedes ejecutar el siguiente comando:

```bash
az aks show -n $AKS_NAME -g $RESOURCE_GROUP --query metricsProfile
```
