# ⚖️ Balanceadores de carga

Ahora que ya tienes una aplicación totalmente funcional, vamos a ver cómo podemos escalarla para que pueda soportar más carga. Para ello, vamos a utilizar un balanceador de carga. **Un balanceador de carga es un dispositivo que distribuye el tráfico de red o las solicitudes de trabajo entre varios servidores**. Los balanceadores de carga se utilizan para aumentar la capacidad de procesamiento de una aplicación web y optimizar su rendimiento, ya que distribuyen el tráfico de red de forma eficiente entre varios servidores.

En Azure, existen dos tipos de balanceadores de carga:

- **Balanceador de carga público**: distribuye el tráfico de red entrante a las máquinas virtuales de Azure. Este balanceador de carga se puede utilizar para equilibrar el tráfico de red a máquinas virtuales que se encuentran en la misma red virtual o en redes virtuales distintas. También se puede utilizar para equilibrar el tráfico de red a máquinas virtuales en distintas regiones de Azure.

- **Balanceador de carga interno**: distribuye el tráfico de red entrante a las máquinas virtuales dentro de una red virtual. Este balanceador de carga se puede utilizar para equilibrar el tráfico de red a máquinas virtuales que se encuentran en la misma red virtual.

En este caso, vamos a utilizar un balanceador de carga público para poder acceder a nuestra aplicación desde Internet. Para ello, vamos a crear un balanceador de carga público. Lo primero que vamos a hacer es setear las variables de entorno que vamos a utilizar para crear el balanceador de carga.

```bash	
# ⚖️ Variables del Balanceador de Carga
LOAD_BALANCER_NAME="frontend-lb"
LB_IP_NAME="tour-of-heroes-lb-ip-$RANDOM"
PROBE_NAME="frontend-probe"
BACKEND_POOL_NAME="tour-of-heroes-backend-pool"
```

o si estás en Windows:

```pwsh
# ⚖️ Variables del Balanceador de Carga
$LOAD_BALANCER_NAME="frontend-lb"
$LB_IP_NAME="tour-of-heroes-lb-ip"
$PROBE_NAME="frontend-probe"
$BACKEND_POOL_NAME="tour-of-heroes-backend-pool"
```

Antes de crear un balanceador de carga público necesitas generar una dirección IP pública. Esta dirección IP pública se utiliza para acceder a las máquinas virtuales que se encuentran detrás del balanceador de carga. Para ello, vamos a crear una dirección IP pública.

```bash
echo -e "📱 Creando dirección IP pública"

az network public-ip create \
--resource-group $RESOURCE_GROUP \
--name $LB_IP_NAME \
--sku Standard \
--dns-name $LB_IP_NAME
```

o si estás en Windows:

```pwsh
Write-Host "📱 Creando dirección IP pública"

az network public-ip create `
--resource-group $RESOURCE_GROUP `
--name $LB_IP_NAME `
--sku Standard `
--dns-name $LB_IP_NAME
```

Y ahora ya si creamos el balanceador:

```bash
echo -e "⚖️ Creando balanceador de carga"

az network lb create \
--resource-group $RESOURCE_GROUP \
--name $LOAD_BALANCER_NAME \
--vnet-name $VNET_NAME \
--sku Standard \
--backend-pool-name $BACKEND_POOL_NAME \
--frontend-ip-name $LB_IP_NAME \
--public-ip-address $LB_IP_NAME
```	

o si estás en Windows:

```pwsh
Write-Host "⚖️ Creando balanceador de carga"

az network lb create `
--resource-group $RESOURCE_GROUP `
--name $LOAD_BALANCER_NAME `
--vnet-name $VNET_NAME `
--sku Standard `
--backend-pool-name $BACKEND_POOL_NAME `
--frontend-ip-name $LB_IP_NAME `
--public-ip-address $LB_IP_NAME
```

Una vez que tenemos el balanceador de carga creado, vamos a crear una sonda de salud para comprobar que nuestra aplicación está funcionando correctamente. Para ello, vamos a crear una sonda de salud que compruebe que la aplicación está funcionando correctamente.

```bash
echo -e "❤️ Creando sonda de salud"

az network lb probe create \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--name $PROBE_NAME \
--protocol tcp \
--port 80
```

o si estás en Windows:

```pwsh
Write-Host "❤️ Creando sonda de salud"

az network lb probe create `
--resource-group $RESOURCE_GROUP `
--lb-name $LOAD_BALANCER_NAME `
--name $PROBE_NAME `
--protocol tcp `
--port 80
```

Una vez que tenemos la sonda de salud creada, vamos a crear una regla de balanceo de carga para que el balanceador de carga pueda distribuir el tráfico de red entre las máquinas virtuales.

```bash
echo -e "🔀 Creando regla de balanceo de carga"

az network lb rule create \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--name myHTTPRule \
--protocol tcp \
--frontend-port 80 \
--backend-port 80 \
--frontend-ip-name $LB_IP_NAME \
--backend-pool-name $BACKEND_POOL_NAME \
--probe-name $PROBE_NAME \
--disable-outbound-snat true \
--idle-timeout 15
```

o si estás en Windows:

```pwsh
Write-Host "🔀 Creando regla de balanceo de carga"

az network lb rule create `
--resource-group $RESOURCE_GROUP `
--lb-name $LOAD_BALANCER_NAME `
--name myHTTPRule `
--protocol tcp `
--frontend-port 80 `
--backend-port 80 `
--frontend-ip-name $LB_IP_NAME `
--backend-pool-name $BACKEND_POOL_NAME `
--probe-name $PROBE_NAME `
--disable-outbound-snat true `
--idle-timeout 15
```

Ahora recuperamos la IP privada de la máquina virtual que hace de frontend y la asignamos al balanceador de carga.

```bash
echo -e "📍 Recuperando IP privada de la VM del frontend"

FRONTEND_VM_PRIVATE_IP=$(az vm show \
--resource-group $RESOURCE_GROUP \
--name $FRONTEND_VM_NAME \
--show-details \
--query privateIps \
--output tsv)

echo -e "➕ Añadiendo VM del frontend al pool de backend"

az network lb address-pool address add  \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--pool-name $BACKEND_POOL_NAME \
--name $FRONTEND_VM_NAME \
--ip-address $FRONTEND_VM_PRIVATE_IP \
--vnet $VNET_NAME
```

o si estás en Windows:

```pwsh
Write-Host "📍 Recuperando IP privada de la VM del frontend"

$FRONTEND_VM_PRIVATE_IP=$(az vm show `
--resource-group $RESOURCE_GROUP `
--name $FRONTEND_VM_NAME `
--show-details `
--query privateIps `
--output tsv)

Write-Host "➕ Añadiendo VM del frontend al pool de backend"

az network lb address-pool address add  `
--resource-group $RESOURCE_GROUP `
--lb-name $LOAD_BALANCER_NAME `
--pool-name frontend-backend-pool `
--name tour-of-heroes-front-end-vm `
--ip-address $FRONTEND_VM_PRIVATE_IP `
--vnet $VNET_NAME 
```

Para comprobar que la configuración es correcta, vamos a acceder a la aplicación a través de la IP pública del balanceador de carga. Para ello, vamos a recuperar la IP pública del balanceador de carga y vamos a acceder a la aplicación a través de ella.

```bash
echo -e "🌐 Accediendo a la VM del frontend usando la IP pública del balanceador"

FRONTEND_LB_PUBLIC_IP=$(az network public-ip show \
--resource-group $RESOURCE_GROUP \
--name $LB_IP_NAME \
--query ipAddress \
--output tsv)

echo -e "📱 Dirección IP pública del balanceador: http://$FRONTEND_LB_PUBLIC_IP"
```

o si estás en Windows:

```pwsh
Write-Host "🌐 Accediendo a la VM del frontend usando la IP pública del balanceador"

$FRONTEND_LB_PUBLIC_IP=$(az network public-ip show `
--resource-group $RESOURCE_GROUP `
--name $PUBLIC_IP_NAME `
--query ipAddress `
--output tsv)

Write-Host "📱 Dirección IP pública del balanceador: http://$FRONTEND_LB_PUBLIC_IP"
```

Como ves, puedes acceder sin problemas al front end a través del balanceador. Para que esto tenga algo más de gracia, vamos a crear otra máquina virtual, exactamente igual que la que tenemos, y vamos a añadirla al balanceador de carga. Para ello, vamos a crear una nueva máquina virtual.

```bash
echo -e "🖥️ Creando VM del frontend #2"

FQDN_FRONTEND_VM_2=$(az vm create \
--resource-group $RESOURCE_GROUP \
--name "${FRONTEND_VM_NAME}-2" \
--image $FRONTEND_VM_IMAGE \
--admin-username $FRONTEND_VM_ADMIN_USERNAME \
--admin-password $FRONTEND_VM_ADMIN_PASSWORD \
--vnet-name $VNET_NAME \
--subnet $FRONTEND_SUBNET_NAME \
--public-ip-address-dns-name $FRONTEND_DNS_LABEL-2 \
--nsg "${FRONTEND_VM_NSG_NAME}-2" \
--size $VM_SIZE --query "fqdns" -o tsv)

az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name "${FRONTEND_VM_NSG_NAME}-2" \
--name AllowHttp \
--priority 1002 \
--destination-port-ranges 80 \
--direction Inbound

az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name "${FRONTEND_VM_NSG_NAME}-2" \
--name Allow8080 \
--priority 1003 \
--destination-port-ranges 8080 \
--direction Inbound

echo -e "⚙️ Ejecutando script para instalar IIS y desplegar Angular"
az vm run-command invoke \
--resource-group $RESOURCE_GROUP \
--name "${FRONTEND_VM_NAME}-2" \
--command-id RunPowerShellScript \
--scripts @04-cloud/azure/iaas/scripts/install-tour-of-heroes-angular.ps1 \
--parameters "api_url=http://$FQDN_API_VM/api/hero" "release_url=https://github.com/0GiS0/tour-of-heroes-angular/releases/download/1.1.4/dist.zip"
```

o si estás en Windows:

```pwsh
Write-Host "🖥️ Creando VM del frontend #2"

$FQDN_FRONTEND_VM_2=$(az vm create `
--resource-group $RESOURCE_GROUP `
--name "${FRONTEND_VM_NAME}-2" `
--image $FRONTEND_VM_IMAGE `
--admin-username $FRONTEND_VM_ADMIN_USERNAME `
--admin-password $FRONTEND_VM_ADMIN_PASSWORD `
--vnet-name $VNET_NAME `
--subnet $FRONTEND_SUBNET_NAME `
--public-ip-address-dns-name tour-of-heroes-frontend-vm `
--nsg $FRONTEND_VM_NSG_NAME `
--size $VM_SIZE --query "fqdns" -o tsv)

az network nsg rule create `
--resource-group $RESOURCE_GROUP `
--nsg-name "${FRONTEND_VM_NSG_NAME}-2" `
--name AllowHttp `
--priority 1002 `
--destination-port-ranges 80 `
--direction Inbound

az network nsg rule create `
--resource-group $RESOURCE_GROUP `
--nsg-name "${FRONTEND_VM_NSG_NAME}-2" `
--name Allow8080 `
--priority 1003 `
--destination-port-ranges 8080 `
--direction Inbound

Write-Host "⚙️ Ejecutando script para instalar IIS y desplegar Angular"
az vm run-command invoke `
--resource-group $RESOURCE_GROUP `
--name "${FRONTEND_VM_NAME}-2" `
--command-id RunPowerShellScript `
--scripts @04-cloud/azure/iaas/scripts/install-tour-of-heroes-angular.ps1 `
--parameters "api_url=http://$FQDN_API_VM/api/hero" "release_url=https://github.com/0GiS0/tour-of-heroes-angular/releases/download/1.1.4/dist.zip"
```

Una vez que tenemos la máquina virtual creada, vamos a recuperar su IP privada y la vamos a añadir al balanceador de carga.

```bash
echo -e "📍 Recuperando IP privada de la VM del frontend #2"

FRONTEND_VM_PRIVATE_IP_2=$(az vm show \
--resource-group $RESOURCE_GROUP \
--name "${FRONTEND_VM_NAME}-2" \
--show-details \
--query privateIps \
--output tsv)

echo -e "➕ Añadiendo VM del frontend #2 al pool de backend"

az network lb address-pool address add  \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--pool-name $BACKEND_POOL_NAME \
--name tour-of-heroes-front-end-vm-2 \
--ip-address $FRONTEND_VM_PRIVATE_IP_2 \
--vnet $VNET_NAME
```

o si estás en Windows:

```pwsh
Write-Host "📍 Recuperando IP privada de la VM del frontend #2"

$FRONTEND_VM_PRIVATE_IP_2=$(az vm show `
--resource-group $RESOURCE_GROUP `
--name "${FRONTEND_VM_NAME}-2" `
--show-details `
--query privateIps `
--output tsv)

Write-Host "➕ Añadiendo VM del frontend #2 al pool de backend"

az network lb address-pool address add  `
--resource-group $RESOURCE_GROUP `
--lb-name $LOAD_BALANCER_NAME `
--pool-name frontend-backend-pool `
--name tour-of-heroes-front-end-vm-2 `
--ip-address $FRONTEND_VM_PRIVATE_IP_2 `
--vnet $VNET_NAME
```

Ahora, si accedemos a la IP pública del balanceador de carga, veremos que la aplicación se muestra de forma aleatoria en una de las dos máquinas virtuales.

```bash
echo -e "🌐 Accediendo a la VM del frontend usando la IP pública del balanceador"

FRONTEND_LB_PUBLIC_IP=$(az network public-ip show \
--resource-group $RESOURCE_GROUP \
--name $LB_IP_NAME \
--query ipAddress \
--output tsv)

echo -e "📱 Dirección IP pública del balanceador: http://$FRONTEND_LB_PUBLIC_IP"
```

o si estás en Windows:

```pwsh
Write-Host "🌐 Accediendo a la VM del frontend usando la IP pública del balanceador"

$FRONTEND_LB_PUBLIC_IP=$(az network public-ip show `
--resource-group $RESOURCE_GROUP `
--name $LB_IP_NAME `
--query ipAddress `
--output tsv)

Write-Host "📱 Dirección IP pública del balanceador: http://$FRONTEND_LB_PUBLIC_IP"
```

La arquitectura en este caso quedaría de la siguiente forma:

![Arquitectura con balanceador de carga](/04-cloud/azure/iaas/images/con-lb.png)

Para eliminar todo lo que hemos creado, solo necesitas eliminar el grupo de recursos que contiene todo.

```bash
echo -e "🗑️ Eliminando grupo de recursos $RESOURCE_GROUP"

az group delete \
--name $RESOURCE_GROUP \
--yes
```

o si estás en Windows:

```pwsh
Write-Host "🗑️ Eliminando grupo de recursos $RESOURCE_GROUP"

az group delete `
--name $RESOURCE_GROUP `
--yes
```