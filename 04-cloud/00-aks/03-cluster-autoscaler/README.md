# Autoescalado de tu clúster en AKS

Lo bueno de estar en la nube es que añadir o eliminar recursos es muy sencillo. En este caso, vamos a ver cómo podemos escalar automáticamente nuestro clúster de AKS en función de la carga que tenga. Por carga se entiendo el número de pods que están corriendo en el clúster.

Como ya tienes un clúster funcionando vamos a actualizar el mismo para decirle hasta cuánto tiene que escalar, en el caso que necesite, y cuál es el mínimo de nodos que tiene que tener.

```bash
az aks update \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_NAME \
    --enable-cluster-autoscaler \
    --min-count 1 \
    --max-count 3
```

Si recuerdas el comando de creación del clúster, le indicamos que tuviera un nodo. Ahora le estamos diciendo que como mínimo tiene que tener uno y como máximo tres. Esto quiere decir que si la carga del clúster es baja, se eliminarán nodos hasta que solo quede uno. Si la carga es alta, se añadirán nodos hasta que haya tres.

Para comprobar que todo está funcionando correctamente, puedes ejecutar este comando:

```bash
kubectl get nodes -w
```
Por otro lado, en otro terminal, vamos a modificar el deployment de la API para que tenga 10 réplicas en lugar de 3, con el fin de que el clúster tenga que escalar.

```bash
kubectl scale deployment tour-of-heroes-api -n tour-of-heroes --replicas=30
kubectl get pods -n tour-of-heroes -l app=tour-of-heroes-api -w
```
Lo primero que te darás cuenta es que varios pods se quedan en estado `Pending`. Esto es porque el clúster no tiene suficientes nodos para poder desplegarlos. Si esperas un poco, verás que el número de nodos se ha incrementado y los pods que estaban en estado `Pending` ya están corriendo.

Si ahora modificas el deployment para que vuelva a tener 3 réplicas, verás que el número de nodos se reduce hasta el mínimo que le hemos indicado.

```bash
kubectl scale deployment tour-of-heroes-api -n tour-of-heroes --replicas=3
```

[En este enlace](https://learn.microsoft.com/es-es/azure/aks/cluster-autoscaler?tabs=azure-cli#cluster-autoscaler-profile-settings) puedes ver las diferentes opciones que puedes modificar relacionadas con el autoescalado.