# Parte 3: ReplicaSets y Deployments

# Empezamos creando un pod de la API go-hello-world
kubectl run helloworld --image lemoncodersbc/go-hello-world  
# Etiquetamos el pod
kubectl label pod helloworld app=helloworld
# Vamos a crear un ReplicaSet. No hay manera de hacerlo imperativamente.
kubectl get pod helloworld -o yaml > helloworld-pod
# Borramos el pod
kubectl delete pod helloworld
# Limpiar "a mano" el YAML y convertirlo a un yaml de ReplicaSet
# El fichero está en helloworld-rs.yaml
kubectl create -f helloworld-rs.yaml
# En este momento deben haber dos pods de helloworld
# Vamos a crear un tercero.
kubectl run helloworld --image lemoncodersbc/go-hello-world  
# Se ha creado? Se está ejecutando?
# Etiquetamos el pod de nuevo
kubectl label pod helloworld app=helloworld
# Qué ha ocurrido al etiquetar el pod? Por qué?

# Recuerda: El ReplicaSet gestiona determinados pods y se basa en las etiquetas que tengan esos pods.
# Para el ReplicaSet dos pods que tengan la misma etiqueta son "iguales".

# Vamos a exponer el RS usando un servicio. Puedes ver el yaml del servicio:
kubectl expose rs/helloworld-rs --port 80 --name helloworld-svc --dry-run=client -o YAML
# Vamos a aplicar dicho yaml
# TIP de kubectl: Observa el create -f -. Eso significa -f <stdin>
kubectl expose rs/helloworld-rs --port 80 --name helloworld-svc --dry-run=client -o YAML | kubectl create -f -

# El servicio es de tipo ClusterIP. Podemos probarlo con port-forward
kubectl port-forward svc/helloworld-svc 9000:80
wget -qO- localhost:9000

# Actualiza el servicio a tipo NodePort / LoadBalancer (depende de tu kubernetes)
# k8s en MV: Usa NodePort
# minikube: Usa LoadBalancer

kubectl delete svc helloworld-svc
kubectl expose rs/helloworld-rs --port 80 --name helloworld-svc --type NodePort # O LoadBalancer
kubectl get svc
# NAME             TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
# helloworld-svc   LoadBalancer   10.108.173.114   <pending>     80:30430/TCP   27s

# En el caso de NodePort el segundo puerto (30430) es el puerto donde está escuchando el servicio en cualquiera
# de los nodos del clúster. Haz un curl a http://<ip-nodo-cluster>:<puerto> y te responderá

# En el caso de LoadBalancer el valor de EXTERNAL-IP te indica la IP a la que debes apuntar. En este caso
# el puerto es 80 (el balanceador hace la redirección interna al puerto del nodo del clúster).
# Minikube es especial (ya que usa LoadBalancer sin existir un balanceador real)
# Debes teclear
# minikube service helloworld-svc
# Eso crea un tunel y te da un puerto temporal sobre localhost:

#|-----------|----------------|-------------|---------------------------|
#| NAMESPACE |      NAME      | TARGET PORT |            URL            |
#|-----------|----------------|-------------|---------------------------|
#| default   | helloworld-svc |          80 | http://192.168.49.2:30430 |
#|-----------|----------------|-------------|---------------------------|
#🏃  Starting tunnel for service helloworld-svc.
#|-----------|----------------|-------------|------------------------|
#| NAMESPACE |      NAME      | TARGET PORT |          URL           |
#|-----------|----------------|-------------|------------------------|
#| default   | helloworld-svc |             | http://127.0.0.1:44319 |
#|-----------|----------------|-------------|------------------------|
#🎉  Opening service default/helloworld-svc in default browser...
#👉  http://127.0.0.1:44319
#❗  Because you are using a Docker driver on linux, the terminal needs to be open to run it.

# Escalamos la replica
kubectl scale rs helloworld --replicas=4

# Deployments

# Empecemos por ver el YAML de un deployment:
kubectl create deployment helloworld --image=lemoncodersbc/go-hello-world --port=80 --replicas=3 --dry-run=client -o yaml
# Creamos el deployment
kubectl create deployment helloworld --image=lemoncodersbc/go-hello-world --port=80 --replicas=3 --dry-run=client -o yaml | kubectl create -f -
kubectl get deployment  # Aparece un deployment
kubectl get pods    # Aparecen 3 pods
kubectl get rs      # Aparece 1 replica set
# Podemos escalar el deployment direcamente. NO HAY NECESIDAD DE INTERACCIONAR CON EL RS
kubectl scale deployment helloworld --replicas=4   # Eso escala el replicaset asociado al deployment.
# Exponemos el deployment
kubectl expose deployment helloworld --port 80 --name helloworld-svc --type LoadBalancer

# Limpieza
kubectl delete svc helloworld-svc
kubectl delete deploy helloworld

# ROLLOUTS
# Empecemos por generar el escenario inicial: Un ReplicaSet (2 replicas) y un servicio 
kubectl create -f rollouts-begin.yaml

# Ahora actualizamos la imagen de los pods asociados al replicaset
kubectl set image rs helloworld-rs *=lemoncodersbc/go-hello-world:invalidtag
# No ocurre nada, ya que los pods siguen corriendo. Hay que forzar que el rs cree los pods nuevos.
# Para ello escalamos a 0 y luego a 2
kubectl scale rs helloworld-rs --replicas=0          
kubectl scale rs helloworld-rs --replicas=2
# ¿Resultado? Los pods están en ImageErrPull
kubectl delete -f rollouts-begin.yaml   # Limpieza

# Vamos a verlo con deployments
kubectl create -f rollouts2-begin.yaml

# Actualizar la imagen del deploy
kubectl set image deployment helloworld *=lemoncodersbc/go-hello-world:invalidtag
# Qué ha ocurrido?
# Ahora tenemos 3 pods. Uno con ImageErrPull y los 2 iniciales
kubectl get po      # Muestra 3 pods
kubectl get rs      # Muestra 2 replicasets
kubectl get deploy  # Muestra 1 solo deployment

# Cual es el estado del rollout?
kubectl rollout status deploy helloworld

# Cual es el histórico de cambios
kubectl rollout history deploy helloworld

# Volvemos para atrás
kubectl rollout undo deploy helloworld

# Cual es la nueva situación?
kubectl get po      # Muestra 3 pods
kubectl get rs      # Muestra 2 replicasets. 1 (el nuevo) con 0 replicas deseadas
kubectl get deploy  # Muestra 1 solo deployment

kubectl delete  -f rollouts2-begin.yaml      # Limpieza

# Vamos a ver ahora un rollout correcto


