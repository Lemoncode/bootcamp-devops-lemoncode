# REPASO
# Ejecutar un pod con la imagen lemoncodersbc/go-hello-world
kubectl run helloworld --image lemoncodersbc/go-hello-world	 --port=80
# Probar el pod usando port-forward
kubectl port-forward helloworld 8080:80

# INSTALAR UN WORDPRESS

# Escenario 1: Dos pods
kubectl run mysql --image mysql:5 --env MYSQL_ROOT_PASSWORD=my-secret-pw  --env MYSQL_DATABASE=lcwp --env MYSQL_USER=eiximenis --env MYSQL_PASSWORD=Pa+a+a1! --port 3306
# Necesitamos obtener la IP. Podemos hacerlo con:
# 1. kubectl get po -o wide
# 2. kubectl get po mysql -o yaml | grep -i IP
# 3. kubectl get po mysql -o jsonpath='{.status.podIP}'
mysqlip=$(kubectl get po mysql -o jsonpath='{.status.podIP}')
# Ahora ejecutamos el pod de wp y le pasamos la IP del pod de mysql
kubectl run wp --image wordpress:php7.2 --env WORDPRESS_DB_HOST=$mysqlip --env WORDPRESS_DB_PASSWORD=Pa+a+a1! --env WORDPRESS_DB_USER=eiximenis --env WORDPRESS_DB_PASSWORD=Pa+a+a1! --env WORDPRESS_DB_NAME=lcwp  --port 80

# Escenario 2: Un pod.
# Creamos el YAML del primer contenedor
kubectl run mysql --image mysql:5 --env MYSQL_ROOT_PASSWORD=my-secret-pw  --env MYSQL_DATABASE=lcwp --env MYSQL_USER=eiximenis --env MYSQL_PASSWORD=Pa+a+a1! --port 3306 --dry-run=client -o yaml > mywp.yaml
# Editar el fichero yaml para añadir el segundo contenedor:
#  - env:
#    - name: WORDPRESS_DB_HOST
#      value: localhost
#    - name: WORDPRESS_DB_NAME
#      value: lcwp
#    - name: WORDPRESS_DB_USER
#      value: eiximenis
#    - name: WORDPRESS_DB_PASSWORD
#      value: Pa+a+a1!
#    image: wordpress:php7.2
#    name: wp
#    ports:
#    - containerPort: 80
#    resources: {}

# NOTA: Tienes el fichero completo en wpall.yaml
# Finalmente usa kubectl create -f

# kubectl create -f mywp.yaml


# SERVICIOS
# Exponer el pod anterior
kubectl expose pod helloworld --name helloworld-svc --port 80
kubectl port-forward svc/helloworld-svc 3000:80          # Ir a localhost:3000

kubectl delete svc helloworld-svc
kubectl delete pod helloworld

# Asignar pods a servicios

# Crear el pod
kubectl run helloweb --image lemoncodersbc/hello-world-web:v1 --port 3000
# Crear el servicio
kubectl expose pod helloweb --port 3000 --name helloweb-svc

# Probar el servicio usando un pod de busybox
kubectl run bb --image busybox -it --rm -- /bin/sh
# Teclear lo siguiente en el terminal que aparece:
# wget -qO- http://helloweb-svc:3000
# exit

# Quitar la label del pod
kubectl label pod helloweb run-
# Probar el servicio usando un pod de busybox
kubectl run bb --image busybox -it --rm -- /bin/sh

# Actualizar el pod otra vez para que vuelva a conectar con el servicio
kubectl label pod helloweb run=helloweb
# Probar el servicio usando un pod de busybox
kubectl run bb --image busybox -it --rm -- /bin/sh

# Borrar el pod y crear otro y ver qué pasa
kubectl delete pod helloweb
kubectl run helloweb --image lemoncodersbc/hello-world-web:v1 --port 3000
# Probar el servicio usando un pod de busybox
kubectl run bb --image busybox -it --rm -- /bin/sh





