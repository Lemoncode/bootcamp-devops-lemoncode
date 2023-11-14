# Comandos vistos

## Gestión de clústers

`kubectl config get-contexts`            # ver contextos configurados
`kubectl config use-context $context`    # Conectarse al contexto indicado
`kubectk config current-context`         # Devuelve el contexto actual

Un contexto es una conexión contra un clúster especificado con unas credenciales determinadas. Los contextos se guardan en `~/.kube/config`

# Relacionados con pods

`kubectl run $pod_name --image $image_name`     # Crea un pod que ejecuta un contenedor con la imagen indicada
                                                # `-it` enlaza terminal
                                                # `--rm`  elimina el pod al terminar el contenedor
                                                # `--restart Never` No reinicia el conteneod si éste termina
`kubectl run bb --imabge busybox -it --rm --restart Never`
`kubectl port-forward $pod_name $local_port:$pod_port`      # Crea un tunel TCP entre el puerto local y el puerto del pod indicado
`kubectl get pods`                              # lista los pods
`kubectl describe pod $pod_name`                # Describe el pod mostrando varios datos en formato textual
`kubectl delete pod $pod_name`                  # Elimina el pod. Para el contenedor automáticamente.
`kubectl exec $pod_name -- $command`            # Ejecuta un comando dentro del contenedor del pod indicado

A todos los comandos se les puede aplicar `-n $namespace` para que apliquen al namespace indicado (`default` por defecto)

# Relacionados con namespaces

`kubectl get ns`                                 # Lista los namespaces


