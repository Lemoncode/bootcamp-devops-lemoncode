# Redes virtuales en Azure

## Creando una red virtual

En nuestro ejemplo de Tour of Heroes vamos a incluir todas las máquinas virtuales dentro de una misma red virtual. Para ello, vamos a definir primero las siguientes variables:

```bash
# Virtual network variables
VNET_NAME="heroes-vnet"
VNET_ADDRESS_PREFIX=192.168.0.0/16
DB_SUBNET_NAME="db-subnet"
DB_SUBNET_ADDRESS_PREFIX=192.168.1.0/24
API_SUBNET_NAME="api-subnet"
API_SUBNET_ADDRESS_PREFIX=192.168.2.0/24
FRONTEND_SUBNET_NAME="frontend-subnet"
FRONTEND_SUBNET_ADDRESS_PREFIX=192.168.3.0/24
```

o si estás en Windows:

```pwsh
# Virtual network variables
$VNET_NAME="heroes-vnet"
$VNET_ADDRESS_PREFIX=192.168.0.0/16
$DB_SUBNET_NAME="db-subnet"
$DB_SUBNET_ADDRESS_PREFIX=192.168.1.0/24
$API_SUBNET_NAME="api-subnet"
$API_SUBNET_ADDRESS_PREFIX=192.168.2.0/24
$FRONTEND_SUBNET_NAME="frontend-subnet"
$FRONTEND_SUBNET_ADDRESS_PREFIX=192.168.3.0/24
```

Para crear una red virtual, ejecuta el siguiente comando:

```bash
echo -e "Creating virtual network $VNET_NAME with address prefix $VNET_ADDRESS_PREFIX and subnet $DB_SUBNET_NAME with address prefix $DB_SUBNET_ADDRESS_PREFIX"

az network vnet create \
--resource-group $RESOURCE_GROUP \
--name $VNET_NAME \
--address-prefixes $VNET_ADDRESS_PREFIX \
--subnet-name $DB_SUBNET_NAME \
--subnet-prefixes $DB_SUBNET_ADDRESS_PREFIX
```

o si estás en Windows:

```bash
echo -e "Creating virtual network $VNET_NAME with address prefix $VNET_ADDRESS_PREFIX and subnet $DB_SUBNET_NAME with address prefix $DB_SUBNET_ADDRESS_PREFIX"

az network vnet create `
--resource-group $RESOURCE_GROUP `
--name $VNET_NAME `
--address-prefixes $VNET_ADDRESS_PREFIX `
--subnet-name $DB_SUBNET_NAME `
--subnet-prefixes $DB_SUBNET_ADDRESS_PREFIX
```

Como ves, durante la creación de la red virtual hemos creado una subred para la base de datos. Ahora vamos a crear las subredes para la API y el frontend:

```bash
echo -e "Creating subnets $API_SUBNET_NAME with address prefix $API_SUBNET_ADDRESS_PREFIX and $FRONTEND_SUBNET_NAME with address prefix $FRONTEND_SUBNET_ADDRESS_PREFIX"

az network vnet subnet create \
--resource-group $RESOURCE_GROUP \
--vnet-name $VNET_NAME \
--name $API_SUBNET_NAME \
--address-prefixes $API_SUBNET_ADDRESS_PREFIX

az network vnet subnet create \
--resource-group $RESOURCE_GROUP \
--vnet-name $VNET_NAME \
--name $FRONTEND_SUBNET_NAME \
--address-prefixes $FRONTEND_SUBNET_ADDRESS_PREFIX
```

o si estás en Windows:

```pwsh
echo -e "Creating subnets $API_SUBNET_NAME with address prefix $API_SUBNET_ADDRESS_PREFIX and $FRONTEND_SUBNET_NAME with address prefix $FRONTEND_SUBNET_ADDRESS_PREFIX"

az network vnet subnet create `
--resource-group $RESOURCE_GROUP `
--vnet-name $VNET_NAME `
--name $API_SUBNET_NAME `
--address-prefixes $API_SUBNET_ADDRESS_PREFIX

az network vnet subnet create `
--resource-group $RESOURCE_GROUP `
--vnet-name $VNET_NAME `
--name $FRONTEND_SUBNET_NAME `
--address-prefixes $FRONTEND_SUBNET_ADDRESS_PREFIX
```

Con esto ya tenemos nuestra red virtual creada. Y tendríamos la foto de la siguiente manera:

![Red virtual con tres subredes](/04-cloud/azure/iaas/images/vnet.png)

Ahora vamos a crear una máquina virtual en cada una de las subredes. [Puedes empezar por aquí con la base de datos](/04-cloud/azure/iaas/01-db-vm/README.md).