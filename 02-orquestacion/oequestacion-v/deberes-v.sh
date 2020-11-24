# Deberes sesión 5 (Ingress)

# En la carpeta /demo-ingress hay 4 manifiestos YAML que despliegan la web y una API.
#
# Crea recursos ingress que:
#
#  1. Expongan la web a través de la ruta my-cluster.com/
#  2. Expongan la api a través de la ruta  my-cluster.com/api
#  3. Expongan la api (otra vez) a través de la ruta api.my-cluster.com
#
# Recuerda que deberás editar el fichero hosts (/etc/hosts o C:\windows\system32\drivers\etc\hosts) y usar como IP para el DNS my-cluster.com y api.my-cluster.com la IP del controlador ingress

# Para instalar un controlador ingress:

# NGINX: https://kubernetes.github.io/ingress-nginx/deploy/

# Si usais minikube: minikube addons enable ingress
# En este caso al crear un ingress os dará una ip (kubectl get ing). Usad esta IP como nombre de host
#
# En MI caso, solo podía acceder a la IP que me daba Minikube a través de un contenedor de Docker enlazado a red de Docker minikube:
#
# docker run --network minikube -it busybox
#
# Eso supongo que es porque uso Minikube con el driver de Docker (donde Kubernetes se ejecuta como un contenedor). No he probado más opciones de Minikube. Si estáis en este caso, podeis hacer la prueba
# desde el contenedor de busybox pero deberéis modificar el fichero /etc/hosts del contenedor y luego usar wget -qO- http://my-cluster.com p.ej.