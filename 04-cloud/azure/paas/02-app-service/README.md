# Azure App Service

Este servicio de Azure nos permite desplegar aplicaciones web y API REST de forma rápida y sencilla. Además, nos permite escalarlas de forma automática y nos ofrece integración con otros servicios de Azure como Azure SQL Database, Azure Cosmos DB, Azure Functions, Azure Storage, Azure Key Vault, Azure Active Directory, etc.

Para este ejemplo, vamos a crear una API REST con ASP.NET Core y la vamos a desplegar en Azure App Service.

Lo primero que necesitas es cargar algunas variables de entorno:

```bash
# App Service variables
APP_SVC_PLAN_NAME="tour-of-heroes-plan"
WEB_API_NAME="tour-of-heroes-api"
```

o si estás en Windows:

```pwsh
# App Service variables
$APP_SVC_PLAN_NAME="tour-of-heroes-plan"
$WEB_API_NAME="tour-of-heroes-api"
```

>Importante: asegúrate de que el nombre de la web app es único en Azure.

## Creando el plan de App Service

Las aplicaciones web alojadas en este servicio necesitan estar dentro de un plan de App Service. Para crear uno, ejecuta el siguiente comando:

```bash
echo -e "Create Azure App Service for the API 🚀"

az appservice plan create \
--name $APP_SVC_PLAN_NAME \
--resource-group $RESOURCE_GROUP \
--location $LOCATION \
--sku S1
```

o si estás en Windows:

```pwsh
echo -e "Create Azure App Service for the API 🚀"

az appservice plan create `
--name $APP_SVC_PLAN_NAME `
--resource-group $RESOURCE_GROUP `
--location $LOCATION `
--sku S1
```

Este es el que determina el tamaño de las máquinas virtuales que se van a utilizar para alojar las aplicaciones web. En este caso, hemos elegido el plan S1.

## Crear la web app para la API

Una vez que tenemos el plan de App Service, lo siguiente es crear la web app para la API. Para ello, ejecuta el siguiente comando:

```bash
az webapp create \
--name $WEB_API_NAME \
--runtime "dotnet:8" \
--resource-group $RESOURCE_GROUP \
--plan $APP_SVC_PLAN_NAME
```

o si estás en Windows:

```pwsh
az webapp create `
--name $WEB_API_NAME `
--runtime "dotnet:8" `
--resource-group $RESOURCE_GROUP `
--plan $APP_SVC_PLAN_NAME
```

## Configurar la web app para la API

Una vez que tenemos la web app creada, podemos añadirle algunas configuraciones. Para ello, ejecuta el siguiente comando:

```bash
az webapp config connection-string set \
--name $WEB_API_NAME \
--resource-group $RESOURCE_GROUP \
--connection-string-type SQLAzure \
--settings "DefaultConnection=Server=tcp:$SQL_SERVER_NAME.database.windows.net,1433;Initial Catalog=heroes-db;Persist Security Info=False;User ID=$SQL_USER;Password=$SQL_PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

az webapp config appsettings set \
--name $WEB_API_NAME \
--resource-group $RESOURCE_GROUP \
--settings "OTEL_SERVICE_NAME=tour-of-heroes-api"
```

o si estás en Windows:

```pwsh
az webapp config connection-string set `
--name $WEB_API_NAME `
--resource-group $RESOURCE_GROUP `
--connection-string-type SQLAzure `
--settings "DefaultConnection=Server=tcp:$SQL_SERVER_NAME.database.windows.net,1433;Initial Catalog=heroes-db;Persist Security Info=False;User ID=$SQL_USER;Password=$SQL_PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
```

```pwsh
az webapp config appsettings set `
--name $WEB_API_NAME `
--resource-group $RESOURCE_GROUP `
--settings "OTEL_SERVICE_NAME=tour-of-heroes-api"
```

En este caso, hemos añadido la cadena de conexión a la base de datos y el nombre del servicio para que se pueda identificar en OpenTelemetry/Azure Monitor.

## Desplegar la API

Ahora que ya tenemos un sitio donde desplegar nuestra API lo único que nos queda es desplegarla 😃.

```bash
echo "Clone the repo..."
git clone https://github.com/0GiS0/tour-of-heroes-dotnet-api.git
cd tour-of-heroes-dotnet-api

dotnet publish tour-of-heroes-api.csproj -o ./publish

cd publish

zip -r site.zip *

az webapp deployment source config-zip \
--src site.zip \
--resource-group $RESOURCE_GROUP \
--name $WEB_API_NAME
```

o si estás en Windows:

```pwsh
echo "Clone the repo..."
git clone https://github.com/0GiS0/tour-of-heroes-dotnet-api.git
cd tour-of-heroes-dotnet-api

dotnet publish tour-of-heroes-api.csproj -o ./publish

cd publish

Compress-Archive -Path * -DestinationPath site.zip

az webapp deployment source config-zip `
--src site.zip `
--resource-group $RESOURCE_GROUP `
--name $WEB_API_NAME
```

Todo esto que hemos hecho a través de Azure CLI también es posible gestionarlos con la extensión de Azure App Service para Visual Studio Code. 

<img src="../images/Extension%20de%20Azure%20App%20Service.png"/>

Para comprobar que todo ha ido bien, puedes ejecutar el siguiente comando:

```bash
echo "API deployed 🚀"
echo "API URL: https://$WEB_API_NAME.azurewebsites.net"
```

Ahora lo único que nos queda por hacer es desplegar el frontal que consuma esta API. Para seguir los pasos puedes continuar en este otro [README](/04-cloud/azure/paas/03-static-web-apps/README.md).
