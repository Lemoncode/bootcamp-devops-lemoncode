# Poner en marcha minikube
minikube start
# Si usas kind
# kind create cluster

# Listar los nodos
kubectl get nodes
kubectl get nodes -o wide # Muestra más info

# Ejecutar un contenedor de un solo uso (hello-world)
kubectl run hello -i --image hello-world --restart=Never --rm

# Los contenedores realmente son pods
kubectl run hello -i --image hello-world --restart=Never # Como antes pero sin --rm
kubectl get po      # o get pod, o get pods

# NAME    READY   STATUS      RESTARTS   AGE
# hello   0/1     Completed   0          7s

# Mostrar datos adicionales (p. ej. la IP interna del pod)
kubectl get po -o wide # Muestra datos adicionales

# Eliminar el pod
kubectl delete po hello

# Un pod por defecto intenta reiniciar el contenedor si ese termina
kubectl run hello --image hello-world 
# Espera unos segundos... La columna RESTARTS será > 0
kubectl get po

# NAME    READY   STATUS      RESTARTS   AGE
# hello   0/1     Completed   2          23s      

kubectl delete po hello         # Limpieza :)

# Pull de la imagen de crash (eiximenis/crash)
# Nota: Puedes construirla tu mismo a partir del Dockerfile en el directorio crash
# Si lo haces debes construirla y subirla a un registro público. Usa el nombre de tu
# imagen en lugar de 'eiximenis/crash'
docker pull eiximenis/crash

# Nunca reiniciar
kubectl run crash1 --image eiximenis/crash --restart=Never
# Pod queda en estado error:
kubectl get po

# NAME     READY   STATUS   RESTARTS   AGE
# crash1   0/1     Error    0          11s

# Pod con reinicio
kubectl run crash2 --image eiximenis/crash 
# Pod se va reiniciando (RESTARTS > 0)
kubectl get po

# NAME     READY   STATUS             RESTARTS   AGE
# crash1   0/1     Error              0          87s
# crash2   0/1     CrashLoopBackOff   2          31s

kubectl delete po crash{1..2}       # Limpieza

# Ejecutar un nginx
kubectl run nginx --image nginx

# Ejecutar una API hello world y exponer puerto 80
kubectl run helloworld --image eiximenis/go-hello-world --port=80
# Usar port-forward para vincular el puerto 8080 local al 80 del pod
kubectl port-forward helloworld 8080:80 
kubectl port-forward helloworld 8080:80 >/dev/null &
curl http://localhost:8080    
# Hello, world! You have called me 1 times.

kill $(ps -ef | grep kubectl | awk {'print $2'})        # Matamos kubectl
kubectl delete pod helloworld                           # Limpieza :)

# Ejecutar nginx con variables de entorno
kubectl run nginx --image nginx --env foo=bar
# Verificar variables
kubectl exec -it nginx -- /bin/sh -c 'env' | grep foo
kubectl delete pod nginx                                # Limpieza :)

# Ejectuar PostgreSQL
kubectl run pgsql --image postgres --env POSTGRES_PASSWORD=123abc!
# Ejecutar Adminer
kubectl run adminer --image adminer --port=8080
# Usar port-forward para acceder
kubectl port-forward adminer 8080:8080
# En este punto abrir navegador a localhost:8080 y entrar en la BBDD.
# Matar kubectl al terminar

# Ver los logs
kubectl logs pgsql
# Usar describe
kubectl describe pod pgsql

kubectl delete po pgsql         # Limpieza :)
kubectl delete pod adminer      # Limpieza :)






