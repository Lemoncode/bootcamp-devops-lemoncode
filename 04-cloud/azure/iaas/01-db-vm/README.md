# Crear máquina virtual para la base de datos

Ahora vamos a crear la máquina virtual para la base de datos. Para ello, vamos a necesitar las siguientes variables de entorno:

```bash
# SQL Server VM on Azure
DB_VM_NAME="db-vm"
DB_VM_IMAGE="MicrosoftSQLServer:sql2022-ws2022:sqldev-gen2:16.0.230613"
DB_VM_ADMIN_USERNAME="dbadmin"
DB_VM_ADMIN_PASSWORD="Db@dmin123#("
DB_VM_NSG_NAME="db-vm-nsg"
```

o si estás en Windows:

```pwsh
# SQL Server VM on Azure
$DB_VM_NAME="db-vm"
$DB_VM_IMAGE="MicrosoftSQLServer:sql2022-ws2022:sqldev-gen2:16.0.230613"
$DB_VM_ADMIN_USERNAME="dbadmin"
$DB_VM_ADMIN_PASSWORD="Db@dmin123!$"
$DB_VM_NSG_NAME="db-vm-nsg"
```

```bash
echo -e "Create a database vm named $DB_VM_NAME with image $DB_VM_IMAGE"

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
echo -e "Create a database vm named $DB_VM_NAME with image $DB_VM_IMAGE"

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

## Crear una cuenta de almacenamiento para los backups

Una buenísima práctica es tener backups de la base de datos. Para ello, vamos a crear una cuenta de almacenamiento en Azure para guardar los backups. Para ello, ejecuta el siguiente comando:

```bash
echo -e "Create a storage acount for the backups"
az storage account create \
--name $STORAGE_ACCOUNT_NAME \
--resource-group $RESOURCE_GROUP \
--location $LOCATION \
--sku Standard_LRS \
--kind StorageV2

STORAGE_KEY=$(az storage account keys list \
--resource-group $RESOURCE_GROUP \
--account-name $STORAGE_ACCOUNT_NAME \
--query "[0].value" \
--output tsv)
```

o si estás en Windows:

```pwsh
echo -e "Create a storage acount for the backups"
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

## Crear la extensión de SQL Server para la máquina virtual de la base de datos

Si estás trabajando con SQL Server en máquinas virtuales en Azure puedes usar la extensión de SQL Server para automatizar las tareas de administración de este tipo de base de datos. Para ello, ejecuta el siguiente comando:

```bash
echo -e "Add SQL Server extension to the database vm"
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

echo -e "Database vm created"
````

o si estás en Windows:

```bash
echo -e "Add SQL Server extension to the database vm"

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

echo -e "Database vm created"
````

## Crear una regla de seguridad de red para SQL Server

Para poder acceder a SQL Server desde la API, vamos a crear una regla de seguridad de red para SQL Server. Para ello, ejecuta el siguiente comando:

```bash
echo -e "Create a network security group rule for SQL Server port 1433"

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

```bash
echo -e "Create a network security group rule for SQL Server port 1433"

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

Por otro lado, si quieres acceder a SQL Server desde tu máquina local, tendrás que crear una regla de seguridad de red para SQL Server para tu dirección IP. Para ello recupera tu dirección IP ejecutando el siguiente comando:

```bash
MY_IP_ADDRESS=$(curl -s ifconfig.me)
echo -e "Your IP address is $MY_IP_ADDRESS"
```

o si estás en Windows:

```bash
$MY_IP_ADDRESS=$(curl -s ifconfig.me)
echo -e "Your IP address is $MY_IP_ADDRESS"
```

Ahora crea la regla de seguridad de red para SQL Server para tu dirección IP ejecutando el siguiente comando:

```bash
echo -e "Create a network security group rule for SQL Server port 1433"

az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name $DB_VM_NSG_NAME \
--name AllowSQLServer \
--priority 1002 \
--destination-port-ranges 1433 \
--protocol Tcp \
--source-address-prefixes $MY_IP_ADDRESS \
--direction Inbound
```

Si estás en Windows, ejecuta el siguiente comando:

```bash
echo -e "Create a network security group rule for SQL Server port 1433"

az network nsg rule create `
--resource-group $RESOURCE_GROUP `
--nsg-name $DB_VM_NSG_NAME `
--name AllowSQLServer `
--priority 1002 `
--destination-port-ranges 1433 `
--protocol Tcp `
--source-address-prefixes $MY_IP_ADDRESS `
--direction Inbound
```

Para probar el acceso te recomiendo usar [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio?view=sql-server-ver15), el cual es multiplataforma. Para ello, descárgalo e instálalo en tu máquina local. Una vez instalado, ejecútalo y en la pantalla de bienvenida, haz clic en **New Connection** y añade la IP pública de la máquina virtual de la base de datos, el usuario y la contraseña. Si no sabes la IP pública de la máquina virtual de la base de datos.

Si por otro lado lo que quieres es acceder a la máquina virtual tendrías que crear una regla de seguridad de red para el puerto 3389. Para ello, ejecuta el siguiente comando:

```bash
echo -e "Create a network security group rule for RDP port 3389"

az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name $DB_VM_NSG_NAME \
--name AllowRDP \
--priority 1003 \
--destination-port-ranges 3389 \
--protocol Tcp \
--source-address-prefixes $MY_IP_ADDRESS \
--direction Inbound
```

Si estás en Windows, ejecuta el siguiente comando:

```bash
echo -e "Create a network security group rule for RDP port 3389"

az network nsg rule create `
--resource-group $RESOURCE_GROUP `
--nsg-name $DB_VM_NSG_NAME `
--name AllowRDP `
--priority 1003 `
--destination-port-ranges 3389 `
--protocol Tcp `
--source-address-prefixes $MY_IP_ADDRESS `
--direction Inbound
```

Ahora que ya tenemos la base de datos creada, necesitamos una API que interactúe con ella. Puedes continuar en el siguiente [paso](../02-api-vm/README.md).