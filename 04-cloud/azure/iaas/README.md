## Desplegando Tour of heroes en máquinas virtuales de Azure

Antes de empezar a montar máquinas virtuales como loc@s lo primero que necesitas es tener una cuenta de Azure. Si no tienes una, puedes crear una cuenta gratuita [aquí](https://azure.microsoft.com/es-es/free/).

Por otro lado, necesitas tener instalado el [CLI de Azure](https://docs.microsoft.com/es-es/cli/azure/install-azure-cli?view=azure-cli-latest) en tu máquina local.

Todos los comandos que te comparto aquí puedes ejecutarlos en un terminal e ir construyendo poco a poco tu entorno. Antes de nada te recomiendo que setees algunas variables de entorno para que no tengas que escribir tanto. Para ello, ejecuta los siguientes comandos:

```bash
# General variables
RESOURCE_GROUP="tour-of-heroes-on-vms"
LOCATION="uksouth"
VM_SIZE="Standard_B2s"
```

o si estás en Windows:

```bash
# General variables
$RESOURCE_GROUP="tour-of-heroes-on-vms"
$LOCATION="uksouth"
$VM_SIZE="Standard_B2s"
```


Una vez que tengas todo esto, debes sabes antes que todo lo que crees en Azure tiene que estar dentro de lo que se conoce como **grupo de recursos**. Un grupo de recursos es un contenedor lógico en el que se despliegan y se administran los recursos de Azure.

Para crear un grupo de recursos, ejecuta el siguiente comando:

```bash
az group create --name <nombre-del-grupo> --location <localización>
```

Por ejemplo:

```bash
az group create --name tour-of-heroes --location westeurope
```

Ahora que ya tienes lo mínimo indispensable, lo siguiente es tener una red virtual. Una red virtual es un grupo de direcciones IP aisladas que solo pueden acceder los recursos de Azure que hayas asignado a la red virtual.