# 🗄️ Azure SQL Database

## ¿Qué es Azure SQL Database?

Es un servicio **PaaS (Platform as a Service)** de Azure que te permite crear bases de datos relacionales en la nube sin preocuparte por la infraestructura subyacente. ¡No más administración de servidores! 🎯

En este ejemplo, vamos a:
- ✅ Crear una base de datos en Azure SQL Database
- ✅ Conectarla con la API de Tour of Heroes

## 📝 Paso 1: Configurar variables de entorno

Carga estas variables en tu terminal:

```bash
# Database variables
SQL_SERVER_NAME="heroes-sql-server-$RANDOM"
SQL_USER="sqladmin"
SQL_PASSWORD="P@ssw0rrd"
startIp="0.0.0.0"
endIp="0.0.0.0"
```

**En Windows PowerShell:**
```pwsh
# Database variables
$SQL_SERVER_NAME="heroes-sql-server-$RANDOM"
$SQL_USER="sqladmin"
$SQL_PASSWORD="P@ssw0rd!"
$startIp="0.0.0.0"
$endIp="0.0.0.0"
```

## 🚀 Paso 2: Crear el servidor de base de datos

Ejecuta este comando para crear un servidor SQL en Azure:

```bash
echo "Creating $SQL_SERVER_NAME in $LOCATION..."

az sql server create --name $SQL_SERVER_NAME \
--resource-group $RESOURCE_GROUP \
--location "$LOCATION" \
--admin-user $SQL_USER \
--admin-password $SQL_PASSWORD
```

**En Windows PowerShell:**
```pwsh
echo "Creating $SQL_SERVER_NAME in $LOCATION..."

az sql server create --name $SQL_SERVER_NAME `
--resource-group $RESOURCE_GROUP `
--location "$LOCATION" `
--admin-user $SQL_USER `
--admin-password $SQL_PASSWORD
```

## 🔥 Paso 3: Configurar el firewall

Entity Framework Core se encargará de crear automáticamente la base de datos cuando la uses. Sin embargo, necesitas permitir el acceso desde otros recursos de Azure.

Ejecuta este comando para configurar las reglas de firewall:

```bash
echo "Configuring firewall..."
az sql server firewall-rule create \
--resource-group $RESOURCE_GROUP \
--server $SQL_SERVER_NAME \
-n AllowYourIp \
--start-ip-address $startIp \
--end-ip-address $endIp
```

**En Windows PowerShell:**
```pwsh
echo "Configuring firewall..."
az sql server firewall-rule create `
--resource-group $RESOURCE_GROUP `
--server $SQL_SERVER_NAME `
-n AllowYourIp `
--start-ip-address $startIp `
--end-ip-address $endIp
```

## 🔗 Paso 4: Verificar la conexión (Opcional)

Con [Azure Data Studio](https://azure.microsoft.com/es-es/products/data-studio) puedes conectarte a tu base de datos para verificar que se creó correctamente. Recuerda que deberás permitir el acceso desde tu IP en las reglas de firewall.

## ➡️ Siguiente paso

Ahora que tienes la base de datos lista, es hora de desplegar la API de Tour of Heroes. Continúa en este [README](../02-app-service/README.md) 📖


