# Crear una máquina virtual para el frontend en Angular
Ahora vamos a crear la máquina virtual para el frontend. Para ello, vamos a necesitar las siguientes variables de entorno:

```bash
# Frontend VM on Azure
FRONTEND_VM_NAME="frontend-vm"
FRONTEND_VM_IMAGE="MicrosoftWindowsServer:WindowsServer:2022-Datacenter:latest"
FRONTEND_VM_ADMIN_USERNAME="frontendadmin"
FRONTEND_VM_ADMIN_PASSWORD="fr0nt#nd@dmin123"
FRONTEND_VM_NSG_NAME="frontend-vm-nsg"
```

o si estás en Windows:

```pwsh
# Frontend VM on Azure
$FRONTEND_VM_NAME="frontend-vm"
$FRONTEND_VM_IMAGE="MicrosoftWindowsServer:WindowsServer:2022-Datacenter:latest"
$FRONTEND_VM_ADMIN_USERNAME="frontendadmin"
$FRONTEND_VM_ADMIN_PASSWORD="fr0nt#nd@dmin123"
$FRONTEND_VM_NSG_NAME="frontend-vm-nsg"
```

Con ellas ya podemos crear la máquina virtual de la misma forma que el resto:

```bash
echo -e "Create a frontend vm named $FRONTEND_VM_NAME with image $FRONTEND_VM_IMAGE"

FQDN_FRONTEND_VM=$(az vm create \
--resource-group $RESOURCE_GROUP \
--name $FRONTEND_VM_NAME \
--image $FRONTEND_VM_IMAGE \
--admin-username $FRONTEND_VM_ADMIN_USERNAME \
--admin-password $FRONTEND_VM_ADMIN_PASSWORD \
--vnet-name $VNET_NAME \
--subnet $FRONTEND_SUBNET_NAME \
--public-ip-address-dns-name tour-of-heroes-frontend-vm \
--nsg $FRONTEND_VM_NSG_NAME \
--size $VM_SIZE --query "fqdns" -o tsv)
```

o si estás en Windows:

```pwsh
echo -e "Create a frontend vm named $FRONTEND_VM_NAME with image $FRONTEND_VM_IMAGE"

$FQDN_FRONTEND_VM=az vm create `
--resource-group $RESOURCE_GROUP `
--name $FRONTEND_VM_NAME `
--image $FRONTEND_VM_IMAGE `
--admin-username $FRONTEND_VM_ADMIN_USERNAME `
--admin-password $FRONTEND_VM_ADMIN_PASSWORD `
--vnet-name $VNET_NAME `
--subnet $FRONTEND_SUBNET_NAME `
--public-ip-address-dns-name tour-of-heroes-frontend-vm `
--nsg $FRONTEND_VM_NSG_NAME `
--size $VM_SIZE --query "fqdns" -o tsv
```

Para que veas que la ejecución de scripts no es solo para máquinas Linux y que también se puede hacer con Windows, vamos a utilizar un script en PowerShell para poder configurar también esta máquina con un IIS y con lo que Angular necesita para poder funcionar.

```bash
echo -e "Execute script to install IIS and deploy tour-of-heroes-angular SPA"
az vm run-command invoke \
--resource-group $RESOURCE_GROUP \
--name $FRONTEND_VM_NAME \
--command-id RunPowerShellScript \
--scripts @04-cloud/azure/iaas/scripts/install-tour-of-heroes-angular.ps1 \
--parameters "api_url=http://$FQDN_API_VM/api/hero" "release_url=https://github.com/0GiS0/tour-of-heroes-angular/releases/download/1.1.4/dist.zip"
```

o si estás en Windows:

```pwsh
echo -e "Execute script to install IIS and deploy tour-of-heroes-angular SPA"

az vm run-command invoke `
--resource-group $RESOURCE_GROUP `
--name $FRONTEND_VM_NAME `
--command-id RunPowerShellScript `
--scripts @scripts/install-tour-of-heroes-angular.ps1 `
--parameters "api_url=http://$FQDN_API_VM/api/hero" "release_url=https://github.com/0GiS0/tour-of-heroes-angular/releases/download/1.1.4/dist.zip"
```

En este ejemplo he desplegado la aplicación en otro puerto, en el 8080, para que no haya conflicto con el IIS que se instala por defecto en el puerto 80. Para elloutilizamos el script [install-tour-of-heroes-angular.ps1](04-cloud/azure/iaas/scripts/install-tour-of-heroes-angular.ps1) que se encuentra en la carpeta **scripts** de este repositorio.

Lo último que nos queda es habilitar los puertos 80 y 8080 en el NSG de la máquina virtual del frontend:

```bash
echo -e "Frontend vm created with FQDN $FQDN_FRONTEND_VM"

az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name $FRONTEND_VM_NSG_NAME \
--name AllowHttp \
--priority 1002 \
--destination-port-ranges 80 \
--direction Inbound

az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name $FRONTEND_VM_NSG_NAME \
--name Allow8080 \
--priority 1003 \
--destination-port-ranges 8080 \
--direction Inbound
```

o si estás en Windows:

```pwsh
echo -e "Frontend vm created with FQDN $FQDN_FRONTEND_VM"

az network nsg rule create `
--resource-group $RESOURCE_GROUP `
--nsg-name $FRONTEND_VM_NSG_NAME `
--name AllowHttp `
--priority 1002 `
--destination-port-ranges 80 `
--direction Inbound

az network nsg rule create `
--resource-group $RESOURCE_GROUP `
--nsg-name $FRONTEND_VM_NSG_NAME `
--name Allow8080 `
--priority 1003 `
--destination-port-ranges 8080 `
--direction Inbound
```

Para probar que todo funciona, abre un navegador y accede a la dirección [http://tour-of-heroes-frontend-vm.uksouth.cloudapp.azure.com:8080](http://tour-of-heroes-frontend-vm.uksouth.cloudapp.azure.com:8080) y deberías ver la aplicación Angular funcionando.

Ahora la arquitectura de nuestra aplicación en Azure debería ser la siguiente:

![Arquitectura de la aplicación en Azure](/04-cloud/azure/iaas/images/todas-las-vm-desplegadas.png)

Si quisieras acceder a la máquina virtual del frontend, deberías habilitar en el NSG el puerto 3389 para poder acceder por RDP.

```bash
az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name $FRONTEND_VM_NSG_NAME \
--name AllowRDP \
--priority 1004 \
--destination-port-ranges 3389 \
--direction Inbound
```

o si estás en Windows:

```pwsh
az network nsg rule create `
--resource-group $RESOURCE_GROUP `
--nsg-name $FRONTEND_VM_NSG_NAME `
--name AllowRDP `
--priority 1004 `
--destination-port-ranges 3389 `
--direction Inbound
```

Y desde el portal de Azure, en la máquina virtual del frontend, en la pestaña **Overview** puedes hacer clic en **Connect** y luego en **Download RDP File** para descargar el fichero de conexión RDP.

Lo último que nos queda es crear un balanceador de carga para poder acceder a la aplicación desde el puerto 80 y no tener que poner el puerto 8080 en la URL. Puedes seguir los pasos [aquí](../04-load-balancer/README.md).