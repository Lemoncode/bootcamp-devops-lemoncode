# Pistas del ejercicio 2

# 2.1 Haz los pods accesibles

- ¿Cuales son los endpoints del servicio?
- No todos los problemas son siempre el selector...

- Para lanzar el pod de busybox el comando ideal es: `kubectl run -it bb --image busybox --rm --restart Never -- /bin/sh`

# 2.2 Ofrece acceso desde el exterior

Aunque podrías usar serviciod `NodePort` o `LoadBalancer`, en general para exponer servicios HTTP/HTTPS existe una opción mejor: ingress

- Recuerda habilitar el controlador de ingress de minikube: `minikube addons enable ingress`
