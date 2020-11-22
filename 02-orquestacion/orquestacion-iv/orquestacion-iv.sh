# Parte 4: Configuración

## Variables de entorno

## Empezamos creando un pod lemoncodersbc/showinfo:v1
kubectl run showinfo –image lemoncodersbc/showinfo:v1
kubectl port-forward 9000:80
curl http://localhost:9000/info

## Borrar el pod
kubectl delete pod showinfo

## Editar el YAML del pod para añadir seeción env con una variable de entorno
kubectl run showinfo --image lemoncodersbc/showinfo:v1 --dry-run=client -o yaml > showinfo.yaml
vi showinfo.yaml

## ConfigMaps

### Crear el configmap
kubectl create cm myconfig --from-literal foo=bar --from-literal foo2=bar2

### Empezamos por obtener el YAMl de un pod que ejecute showinfo
kubectl run showinfo --image lemoncodersbc/showinfo:v1 --dry-run=client -o yaml > showinfo.yaml
vi showinfo.yaml

### Añadir sección de env usando ahora valueFrom
### Usar envFrom

## Crear el secreto
kubectl create secret generic mysecret --from-literal foo=bar --from-literal foo2=bar2
### Secretos son base64
kubect get secret mysecret -o yaml 
### Empezamos por obtener el YAMl de un pod que ejecute showinfo
kubectl run showinfo --image lemoncodersbc/showinfo:v1 --dry-run=client -o yaml > showinfo.yaml
vi showinfo.yaml

### Añadir sección de env usando ahora valueFrom
### Usar envFrom

## Volúmenes y configuración

### Configurar un NGINX a partir de un cm

kubectl create configmap nginx --from-file nginx.conf=nginx.conf            ## Creamos el configmap

kubectl run nginx --image nginx -o yaml --dry-run=client > nginx.yaml       ## Obtener el yaml de un pod de nginx
vi nginx.yaml

### Editar volumen y volumeMount para montar el fichero nginx.conf

