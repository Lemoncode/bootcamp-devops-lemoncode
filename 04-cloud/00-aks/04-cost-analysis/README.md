# Cómo saber cuánto cuestan tus Pods en AKS

Desde hace poco tiempo, todavía en preview, Azure nos permite saber cuánto nos cuesta cada uno de los pods que tenemos en nuestro cluster de Kubernetes. Esto es muy útil para saber qué pods son los que más recursos consumen y, por tanto, los que más nos cuestan.

Para habilitar esta funcionalidad debes instalar una extensión para la CLI de Azure. Para ello, ejecuta el siguiente comando:

```bash
az extension add --name aks-preview
```

Una vez la tengas podrás actualizar tu clúster:

```bash
az aks update -n $AKS_NAME \
-g $RESOURCE_GROUP \
--tier standard \
--enable-cost-analysis
```
Con esta característica habilitada, podrás ver el coste de cada uno de los pods de tu cluster de Kubernetes. [Aquí tienes la documentación donde se explica cómo](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/view-kubernetes-costs). Simplemente acude al portal de Azure > Busca Cost Management y en el combo selecciona **Kubernetes clusters**. Puedes obtener una vista por namespace y dentro de este ver el coste de cada uno de los pods.