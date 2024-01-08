# Azure SQL Database

Se trata de un servicio PaaS de Azure que nos permite crear bases de datos relacionales en la nube sin necesidad de tener que administrar la infraestructura subyacente.

Para este ejemplo, vamos a crear una base de datos en Azure SQL Database y vamos a conectarla con la API de Tour of heroes.

Lo primero que necesitas es cargar algunas variables de entorno:

```bash
# Database variables
SQL_SERVER_NAME="heroes-sql-server"
SQL_USER="sqladmin"
SQL_PASSWORD="P@ssw0rrd"
startIp="0.0.0.0"
endIp="0.0.0.0"
```

o si estás en Windows:

```pwsh
# Database variables
$SQL_SERVER_NAME="heroes-sql-server"
$SQL_USER="sqladmin"
$SQL_PASSWORD="P@ssw0rd!"
$startIp="0.0.0.0"
$endIp="0.0.0.0"
```

## Creando la base de datos

Para crear una base de datos en Azure SQL Database, lo primero que tienes que hacer es crear un servidor de base de datos. Para ello, ejecuta el siguiente comando:

```bash
echo "Creating $SQL_SERVER_NAME in $LOCATION..."

az sql server create --name $SQL_SERVER_NAME \
--resource-group $RESOURCE_GROUP \
--location "$LOCATION" \
--admin-user $SQL_USER \
--admin-password $SQL_PASSWORD
```

o si estás en Windows:

```pwsh
echo "Creating $SQL_SERVER_NAME in $LOCATION..."

az sql server create --name $SQL_SERVER_NAME `
--resource-group $RESOURCE_GROUP `
--location "$LOCATION" `
--admin-user $SQL_USER `
--admin-password $SQL_PASSWORD
```

En este ejemplo no necesitamos crear la base de datos, ya que nuestra API, que hace uso de Entity Framework Core, se encargará de crearla por nosotros.

Lo que si es necesario es que permitamos el acceso a la base de datos desde otros recursos de Azure. Para ello, ejecuta el siguiente comando:

```bash
echo "Configuring firewall..."
az sql server firewall-rule create \
--resource-group $RESOURCE_GROUP \
--server $SQL_SERVER_NAME \
-n AllowYourIp \
--start-ip-address $startIp \
--end-ip-address $endIp
```

o si estás en Windows:

```pwsh
echo "Configuring firewall..."
az sql server firewall-rule create `
--resource-group $RESOURCE_GROUP `
--server $SQL_SERVER_NAME `
-n AllowYourIp `
--start-ip-address $startIp `
--end-ip-address $endIp
```

Con [Azure Data Studio](https://azure.microsoft.com/es-es/products/data-studio), puedes conectarte a la base de datos (tienes que permitir entonces el acceso desde tu IP, que puedes hacerlo desde esta misma app) y comprobar que se ha creado correctamente e incluso podrías crear la base de datos desde aquí.

Ahora lo siguiente que necesitamos es desplegar la API que haga uso de esta base de datos. Para ello, puedes seguir los pasos que te comparto en este otro [README](/04-cloud/azure/paas/02-app-service/README.md).


