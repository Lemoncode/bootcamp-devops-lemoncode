# 💾 Crear máquina virtual para la base de datos

Ahora vamos a crear la máquina virtual para la base de datos. Para ello, vamos a necesitar las siguientes variables de entorno:

```bash
# 🗄️ SQL Server VM en Azure
DB_VM_NAME="db-vm"
DB_VM_IMAGE="MicrosoftSQLServer:sql2022-ws2022:sqldev-gen2:16.0.230613"
DB_VM_ADMIN_USERNAME="dbadmin"
DB_VM_ADMIN_PASSWORD="Db@dmin123#-"
DB_VM_NSG_NAME="db-vm-nsg"
```

o si estás en Windows:

```pwsh
# 🗄️ SQL Server VM en Azure
$DB_VM_NAME="db-vm"
$DB_VM_IMAGE="MicrosoftSQLServer:sql2022-ws2022:sqldev-gen2:16.0.230613"
$DB_VM_ADMIN_USERNAME="dbadmin"
$DB_VM_ADMIN_PASSWORD="Db@dmin123!$"
$DB_VM_NSG_NAME="db-vm-nsg"
```

```bash
echo -e "🖥️ Creando máquina virtual de base de datos $DB_VM_NAME"

az vm create \
--resource-group $RESOURCE_GROUP \
--name $DB_VM_NAME \
--image $DB_VM_IMAGE \
--admin-username $DB_VM_ADMIN_USERNAME \
--admin-password $DB_VM_ADMIN_PASSWORD \
--vnet-name $VNET_NAME \
--subnet $DB_SUBNET_NAME \
--public-ip-address "" \
--size $VM_SIZE \
--nsg $DB_VM_NSG_NAME
```

o si estás en Windows:

```pwsh
echo -e "🖥️ Creando máquina virtual de base de datos $DB_VM_NAME"

az vm create `
--resource-group $RESOURCE_GROUP `
--name $DB_VM_NAME `
--image $DB_VM_IMAGE `
--admin-username $DB_VM_ADMIN_USERNAME `
--admin-password $DB_VM_ADMIN_PASSWORD `
--vnet-name $VNET_NAME `
--subnet $DB_SUBNET_NAME `
--public-ip-address "" `
--size $VM_SIZE `
--nsg $DB_VM_NSG_NAME 
```

Esta no necesita tener acceso desde fuera de la red virtual en la que se encuentra, por lo que no le asignamos una IP pública. Por otro lado, le hemos añadido un network security group (a través del parámetro --nsg), el cual es un conjunto de reglas que permiten o deniegan el tráfico de red entrante o saliente de los recursos de Azure.

<!-- ## 💾 Crear una cuenta de almacenamiento para los backups

Una buenísima práctica es tener backups de la base de datos. Para ello, vamos a crear una cuenta de almacenamiento en Azure para guardar los backups. Para ello, ejecuta el siguiente comando:

```bash
echo -e "📦 Creando cuenta de almacenamiento para backups"
az storage account create \
--name $STORAGE_ACCOUNT_NAME \
--resource-group $RESOURCE_GROUP \
--location $LOCATION \
--sku Standard_LRS \
--kind StorageV2 \
--allow-shared-key-access true

STORAGE_KEY=$(az storage account keys list \
--resource-group $RESOURCE_GROUP \
--account-name $STORAGE_ACCOUNT_NAME \
--query "[0].value" \
--output tsv)
```

o si estás en Windows:

```pwsh
echo -e "📦 Creando cuenta de almacenamiento para backups"
az storage account create `
--name $STORAGE_ACCOUNT_NAME `
--resource-group $RESOURCE_GROUP `
--location $LOCATION `
--sku Standard_LRS `
--kind StorageV2

$STORAGE_KEY=$(az storage account keys list `
--resource-group $RESOURCE_GROUP `
--account-name $STORAGE_ACCOUNT_NAME `
--query "[0].value" `
--output tsv)
```

>Importante: Debes tener en cuenta que el nombre de la cuenta de almacenamiento debe ser único en Azure. Si te da un error, prueba a cambiar el nombre. -->

## ⚙️ Crear la extensión de SQL Server para la máquina virtual de la base de datos

Si estás trabajando con SQL Server en máquinas virtuales en Azure puedes usar la extensión de SQL Server gestionar esa máquina virtual con un sabor de base de datos. Para ello, ejecuta el siguiente comando:

<!-- 
```bash
echo -e "⚙️ Añadiendo extensión de SQL Server a la VM de base de datos"
az sql vm create \
--name $DB_VM_NAME \
--license-type payg \
--resource-group $RESOURCE_GROUP \
--location $LOCATION \
--connectivity-type PRIVATE \
--port 1433 \
--sql-auth-update-username $DB_VM_ADMIN_USERNAME \
--sql-auth-update-pwd $DB_VM_ADMIN_PASSWORD \
--backup-schedule-type manual \
--full-backup-frequency Weekly \
--full-backup-start-hour 2 \
--full-backup-duration 2 \
--storage-account "https://$STORAGE_ACCOUNT_NAME.blob.core.windows.net/" \
--sa-key $STORAGE_KEY \
--retention-period 30 \
--log-backup-frequency 60

echo -e "✅ Extensión de base de datos creada"
```

o si estás en Windows:

```bash
echo -e "⚙️ Añadiendo extensión de SQL Server a la VM de base de datos"

az sql vm create `
--name $DB_VM_NAME `
--license-type payg `
--resource-group $RESOURCE_GROUP `
--location $LOCATION `
--connectivity-type PRIVATE `
--port 1433 `
--sql-auth-update-username $DB_VM_ADMIN_USERNAME `
--sql-auth-update-pwd $DB_VM_ADMIN_PASSWORD `
--backup-schedule-type manual `
--full-backup-frequency Weekly `
--full-backup-start-hour 2 `
--full-backup-duration 2 `
--storage-account "https://$STORAGE_ACCOUNT_NAME.blob.core.windows.net/" `
--sa-key $STORAGE_KEY `
--retention-period 30 `
--log-backup-frequency 60

echo -e "Database extension created"
``` -->

```bash
echo -e "⚙️ Añadiendo extensión de SQL Server a la VM de base de datos"
az sql vm create \
--name $DB_VM_NAME \
--license-type payg \
--resource-group $RESOURCE_GROUP \
--sql-mgmt-type Lightweight

echo -e "✅ Extensión de base de datos creada"
```

o si estás en Windows:

```pwsh
echo -e "⚙️ Añadiendo extensión de SQL Server a la VM de base
az sql vm create `
--name $DB_VM_NAME `
--license-type payg `
--resource-group $RESOURCE_GROUP `
--sql-mgmt-type Lightweight 
```

## 🔒 Crear una regla de seguridad de red para SQL Server

Para poder acceder a SQL Server desde la API, vamos a crear una regla de seguridad de red para SQL Server. Para ello, ejecuta el siguiente comando:

```bash
echo -e "🔒 Creando regla de seguridad para SQL Server puerto 1433"

az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name $DB_VM_NSG_NAME \
--name AllowSQLServer \
--priority 1001 \
--destination-port-ranges 1433 \
--protocol Tcp \
--source-address-prefixes $API_SUBNET_ADDRESS_PREFIX \
--direction Inbound
```

o si estás en Windows:

```pwsh
echo -e "🔒 Creando regla de seguridad para SQL Server puerto 1433"

az network nsg rule create `
--resource-group $RESOURCE_GROUP `
--nsg-name $DB_VM_NSG_NAME `
--name AllowSQLServer `
--priority 1001 `
--destination-port-ranges 1433 `
--protocol Tcp `
--source-address-prefixes $API_SUBNET_ADDRESS_PREFIX `
--direction Inbound
```

Esto lo que significa es que vamos a permitir el tráfico desde la subred de la API a la máquina virtual de la base de datos en el puerto 1433. Si se intenta acceder desde otra subred, no te va a dejar.

Quedando la foto de la siguiente manera:

![VM para la base de datos](/04-cloud/azure/iaas/images/db-vm.png)

Ahora que ya tenemos la base de datos creada, necesitamos una API que interactúe con ella. Puedes continuar en el siguiente [paso](../02-api-vm/README.md) 🚀.