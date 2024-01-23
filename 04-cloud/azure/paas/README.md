## Desplegando Tour of heroes en servicios PaaS de Azure

Antes de empezar a montar servicios PaaS como loc@s lo primero que necesitas es tener una cuenta de Azure. Si no tienes una, puedes crear una gratuita [aquí](https://azure.microsoft.com/es-es/free/).

Por otro lado, necesitas tener instalado el [CLI de Azure](https://docs.microsoft.com/es-es/cli/azure/install-azure-cli?view=azure-cli-latest) en tu máquina local.

Todos los comandos que te comparto aquí puedes ejecutarlos en un terminal e ir construyendo poco a poco tu entorno.

Una vez que tengas una cuenta de Azure y el CLI instalado, lo primero que tienes que hacer es logarte en tu cuenta de Azure desde el CLI. Para ello, ejecuta el siguiente comando:

```bash
az login
```

Una vez hecho esto, te recomiendo que setees algunas variables de entorno para que no tengas que escribir tanto, ni acordarte de los nombres que has dado a los recursos que crearemos a continuación. Para ello, ejecuta los siguientes comandos:

```bash
# General variables
RESOURCE_GROUP="tour-of-heroes-paas"
LOCATION="uksouth"
```
o si estás en Windows:

```pwsh
# General variables
$RESOURCE_GROUP="tour-of-heroes-paas"
$LOCATION="uksouth"
```

Una vez que las tengas cargadas en tu terminal, deber saber que todo lo que crees en Azure tiene que estar dentro de lo que se conoce como **grupo de recursos**. Un grupo de recursos es un contenedor lógico en el que se despliegan y se administran los recursos de Azure.

Para crear uno, ejecuta el siguiente comando:

```bash
az group create --name $RESOURCE_GROUP --location $LOCATION
```

Ahora que ya tienes lo mínimo indispensable, vamos a empezar creando la base de datos. Para seguir los pasos puedes hacerlo en este otro [README](/04-cloud/azure/paas/01-sql-database/README.md).