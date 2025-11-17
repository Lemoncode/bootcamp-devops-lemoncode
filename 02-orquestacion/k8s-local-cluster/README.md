# Modulo 3 - Kubernetes

## Despligue de un cluster de Kubernetes para laboratorio
[[Ir al script]](https://gitlab.com/imanolvalero/lemoncode-devops/blob/main/modulo3-kubernetes/k8s-local-cluster/k8s-local-cluster.sh)

He hecho este script para automatizar, bajo mi entorno (linux+libvirt), los pasos del repositorio [k8s-fundamentals](https://github.com/Lemoncode/k8s-fundamentals) de [Lemoncode](https://github.com/Lemoncode), donde [Santiago Camargo Rodríguez](https://github.com/crsanti) detalla cómo instalar un cluster de `Kubernetes` usando `containerd`.

[[ Ir a la carpeta donde se detallan los pasos]](https://github.com/Lemoncode/k8s-fundamentals/tree/main/00-installing-k8s/02-kubeadm-local-containerd)

### Requisitos
Este script está pensado para correr en `Linux` y montar las máquinas virtuales sobre `libvirt`
* Utiliza `Vagrant` para realizar el despliegue de las maquinas virtuales
* Utiliza `Ansible` para automatizar las instalaciones y configuraciones necesarias

### Uso del script
El script `deploy.sh` despliega, por defecto, un cluster de kubernetes, con 1 controlador y 3 workers

Esta es la salida de `--help`
```
Kubernetes laboratory deploy automated tool
Options:
-p, --project           project name.
                        will override value of env K8LAB_PROJECT
                        default: <current-directory-name>
-cc, --controller-cpus  controller node CPU quantity.
                        will override value of env K8LAB_CONTROLLER_CPUS
                        default: 2
-cr, --controller-ram   controller node RAM ammount.
                        will override value of env K8LAB_CONTROLLER_RAM
                        default: 2048
-w,  --workers          worker node quantity.
                        will override value of env K8LAB_WORKER_QUANTITY
                        default: 3
-wc, --worker-cpus      worker node CPU quantity.
                        will override value of env K8LAB_WORKER_CPUS
                        default: 2
-wr, --worker-ram       worker node RAM ammount.
                        will override value of env K8LAB_WORKER_RAM
                        default: 1024
-kd, --k8s-flavour      flavour kubernetes-* to install from 
                        https://packages.cloud.google.com/apt/dists.
                        will override value of env K8LAB_K8S_FLAVOUR
                        Default: xenial
-kv, --k8s-version      version of packages to install
                        will override value of env K8LAB_K8S_VERSION
                        Default: 1.22.3-00
-b,  --box              box of Vagrant to use.
                        will override value of env K8LAB_BOX
                        Default: generic/ubuntu1804
-s, --subnet            IP/24 of the nodes subnet. 
                        will override value of env K8LAB_SUBNET
                        Default: 10.224.114.0
-h,  --help             prints this help message.
```


### Archivos que genera
Este script, genera los siguientes archivos en la carpeta de proyecto:
* El archivo `Vagrantfile` para el despliegue de las máquinas virtuales
* El archivo `.inventory.ini` para la configuragion de los nodos
* El directorio `.vagrant`, que lo genera `Vagrant` para la gestion de máquinas virtuales
* El archivo `.kubeconfig` para poder gestionar el cluster desde el directorio del proyecto


### Gestion del cluster creado
Después de lanzar con éxito este script, podrás controlar el cluster usando el archivo de configuración `.kubeconfig`.
Por ejemplo:
```bash
kubectl --kubeconfig .kubeconfig get nodes
```

### Eliminar el cluster
Se puede eliminar el cluster con el siguiente comando
```bash
Vagrant destroy --force
```

Si se ha roto la configuracion de Vagrant, también se puede limpiar el entorno usando el comando [virsh](https://www.libvirt.org/manpages/virsh.html) o desde la interfaz de usuario que proporciona [virt-manager](https://virt-manager.org/)