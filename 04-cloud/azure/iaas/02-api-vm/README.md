# 🔌 Crear la máquina virtual para la API en .NET

Para esta pieza de la arquitectura de Tour of Heroes vamos a usar una máquina virtual que utilice como sistema operativo Ubuntu. Para este componente vas a necesitar que cargues las siguientes variables:

```bash
# 🔌 API VM en Azure
API_VM_NAME="api-vm"
API_VM_DNS_LABEL="tour-of-heroes-api-vm-$RANDOM"
API_VM_IMAGE="Ubuntu2204"
API_VM_ADMIN_USERNAME="apiadmin"
API_VM_ADMIN_PASSWORD="Api@dmin-1232"
API_VM_NSG_NAME="api-vm-nsg"
```

o si estás en Windows:

```pwsh
# 🔌 API VM en Azure
$API_VM_NAME="api-vm"
$API_VM_DNS_LABEL="tour-of-heroes-api-vm-$RANDOM"
$API_VM_IMAGE="Ubuntu2204"
$API_VM_ADMIN_USERNAME="apiadmin"
$API_VM_ADMIN_PASSWORD="Api@dmin1232!"
$API_VM_NSG_NAME="api-vm-nsg"
```

Ahora con estas vamos a crear la máquina virtual de la misma forma que lo hicimos con la base de datos:

```bash
echo -e "🖥️ Creando VM de API $API_VM_NAME"

FQDN_API_VM=$(az vm create \
--resource-group $RESOURCE_GROUP \
--name $API_VM_NAME \
--image $API_VM_IMAGE \
--admin-username $API_VM_ADMIN_USERNAME \
--admin-password $API_VM_ADMIN_PASSWORD \
--vnet-name $VNET_NAME \
--subnet $API_SUBNET_NAME \
--public-ip-address-dns-name $API_VM_DNS_LABEL \
--nsg $API_VM_NSG_NAME \
--size $VM_SIZE --query "fqdns" -o tsv)

echo -e "✅ VM de API creada"
```

o si estás en Windows:

```pwsh
echo -e "🖥️ Creando VM de API $API_VM_NAME"

$FQDN_API_VM=az vm create `
--resource-group $RESOURCE_GROUP `
--name $API_VM_NAME `
--image $API_VM_IMAGE `
--admin-username $API_VM_ADMIN_USERNAME `
--admin-password $API_VM_ADMIN_PASSWORD `
--vnet-name $VNET_NAME `
--subnet $API_SUBNET_NAME `
--public-ip-address-dns-name $API_VM_DNS_LABEL `
--nsg $API_VM_NSG_NAME `
--size $VM_SIZE --query "fqdns" -o tsv

echo -e "✅ VM de API creada"
```

Sin embargo, con esto solo no basta ya que por ahora sólo tenemos la máquina virtual pero no está ni configurada para poder hospedar mi API en .NET ni configurado ningún servidor web que la sirva. Para ello vamos a hacer uso del subcomando **run-command** de la CLI de Azure. Este nos permite ejecutar comandos en la máquina virtual de forma remota:

```bash
# https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/linux-nginx?view=aspnetcore-7.0&tabs=linux-ubuntu
echo -e "⚙️ Ejecutando script para instalar Nginx, .NET Core y la API"
az vm run-command invoke \
--resource-group $RESOURCE_GROUP \
--name $API_VM_NAME \
--command-id RunShellScript \
--scripts @04-cloud/azure/iaas/scripts/install-tour-of-heroes-api.sh \
--parameters https://github.com/0GiS0/tour-of-heroes-dotnet-api/releases/download/1.0.5/drop.zip $FQDN_API_VM $DB_VM_ADMIN_USERNAME $DB_VM_ADMIN_PASSWORD
```

o si estás en Windows:

```pwsh
# https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/linux-nginx?view=aspnetcore-7.0&tabs=linux-ubuntu
echo -e "⚙️ Ejecutando script para instalar Nginx, .NET Core y la API"
az vm run-command invoke `
--resource-group $RESOURCE_GROUP `
--name $API_VM_NAME `
--command-id RunShellScript `
--scripts @04-cloud/azure/iaas/scripts/install-tour-of-heroes-api.sh `
--parameters https://github.com/0GiS0/tour-of-heroes-dotnet-api/releases/download/1.0.5/drop.zip $FQDN_API_VM $DB_VM_ADMIN_USERNAME $DB_VM_ADMIN_PASSWORD
```

Con este comando estamos ejecutando un script que se encuentra en la carpeta **scripts** de este repositorio. El mismo se encarga de instalar Nginx, .NET Core, desplegar la API y crear un servicio que la mantenga en ejecución. Si quieres ver el contenido del script puedes hacerlo [aquí](04-cloud/azure/iaas/scripts/install-tour-of-heroes-api.sh).

Por último necesitamos crear una **network security rule** para permitir el acceso a través del puerto 80 a la API:

```bash
echo -e "🔒 Creando regla de seguridad para permitir puerto 80"
az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name $API_VM_NSG_NAME \
--name AllowHttp \
--priority 1002 \
--destination-port-ranges 80 \
--direction Inbound
```

o si estás en Windows:

```pwsh
echo -e "🔒 Creando regla de seguridad para permitir puerto 80"

az network nsg rule create `
--resource-group $RESOURCE_GROUP `
--nsg-name $API_VM_NSG_NAME `
--name AllowHttp `
--priority 1002 `
--destination-port-ranges 80 `
--direction Inbound
```

Si instalas la extensión REST Client en tu Visual Studio Code, puedes ejecutar la peticiones que aparecen el fichero [api.http](04-cloud/azure/iaas/02-api-vm/api.http).

Para comprobar que la API funciona correctamente podemos acceder a la URL:

```bash
echo "http://$API_VM_DNS_LABEL.$LOCATION.cloudapp.azure.com/api/hero"
 ```

En este ejemplo (en tu despliegue deberías modificarla por la que corresponda) y deberías ver un listado de héroes en formato JSON.

El resultado hasta ahora debería ser el siguiente:

![VM para la API](/04-cloud/azure/iaas/images/api-vm-y-db-vm.png)

Y con esto ya tendríamos la API desplegada en una máquina virtual de Azure. Ahora vamos a desplegar el frontend en otra máquina virtual de Azure. Puedes continuar en el siguiente [paso](../03-frontend-vm/README.md) 🚀.