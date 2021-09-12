# Windows WSL 1, ejecutando Docker y K8s
 
Correr Docker en `WSL 1` no es el método recomendado. Existen ocasiones, en que no es posible poder instalar en nuestras máquinas `WSL 2`. Una buena alternativa a esto es usar un `VMs` y ejecutar los contenedores de manera nativa (en Linux).
 
Con respecto a tener `K8s` corriendo en local, uno de los métodos existentes más directo que existe, es utilizar `minikube`. Existen distintas maneras de correr `minikube`, pero básicamente, se trata de un máquina virtual, a la cuál la tenemos que proveer de un *driver* (VirtualBox, VMWare...) para que pueda correr el *clúster* de `K8s`. 

>IMPORTANTE: Ejecutar Vagrant con WSL como driver está en beta. Para seguir esta guía de manera directa, la mejor opción es no tener hábilitadas las características de WSL en nuestar máquina.
 
## Instalando en Windows - Chocolatey
 
En el mundo Linux, tenemos gestores de paquetes para instalar software, podemos obtener lo mismo en Windows con [Chocolatey](https://chocolatey.org/). Una vez instalado `Chocolatey`, las instalaciones serán deliciosas ;)
 
Para instalar `Chocolatey` podemos seguir la [guía oficial](https://chocolatey.org/install)
 
## Instalando Dependencias - Driver VM
 
Una vez instalado `Chocolatey`, podemos instalar `VirtualBox` de la siguiente manera:
 
```bash
choco install virtualbox
```
 
## Instalando Dependencias - Vagrant
 
La gestión de las VMs puede ser algo realmente complejo, afortunadamente [Vagrant](https://www.vagrantup.com/) nos lo pone fácil. Para instalar `Vagrant`, simplemente ejecutamos:
 
```bash
choco install vagrant
```
 
## Ejecutando Docker
 
Estamos listos para poder usar Docker. Crear el fichero `Vagrantfile` en la carpeta que prefiramos.
 
```ruby
Vagrant.configure("2") do |config|
 config.vm.box = "bento/ubuntu-18.04"
 config.vm.network "private_network", ip: "192.168.50.4"
 config.vm.provision "docker"
end
 
```
 
Una vez haya terminado la instalación podemos acceder a la máquina virtual ejecutando
 
```bash
vagrant ssh
```
 
Una vez aquí podemos comprobar que Docker esta corriendo:
 
```bash
docker version
```
 
Como último paso vamos a ejecutar un contenedor que exponga un servicio web y acceder desde el `host` (nuestra máquina):
 
```bash
docker run -d -p 80:80 nginx:alpine
```
 
En el script que define esta VM, generamos un red privada con *la IP estática `192.168.50.4`*. Por defecto, el `host` a estas IPs, si pegamos en el navegador `http://192.168.50.4/` veremos la página por defecto de `Nginx`. 
 
Para salir de la VM:
 
```bash
exit
```
 
Para parar la VM:
 
```bash
vagrant halt
```
 
Si queremos destruir la máquina virtual:
 
```bash
vagrant destroy
```
 
## Instalando K8s
 
Para instalar `K8s`:
 
```bash
choco install minikube
```
 
Una vez termine la instalación tendremos todo preparado para empezar a usar `K8s` de forma local. Para comprobar que la instalación ha tenido éxito, podemos ejecutar:
 
```bash
kubectl get all
```
 
Deberíamos ver una salida similar a esta:
 
```bash
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   59s
```
 
Para parar la VM de `minikube` ejecutamos:
 
```bash
minikube stop
```
 
Cuando la queramos arrancar:
 
```bash
minikube start
```
