# Desplegar contenedores con Azure Container Apps

Hasta ahora hemos trabajado con AKS, que es la opción más potente para orquestar contenedores en Azure. Pero, ¿y si no necesitas toda esa potencia? ¿Y si solo quieres desplegar tus contenedores sin complicarte la vida con nodos, networking, ingress controllers y demás?

Para eso está **Azure Container Apps (ACA)**: una plataforma serverless que te permite ejecutar contenedores sin gestionar la infraestructura subyacente. Algunos lo llaman **Kubernetesless** porque, aunque por debajo usa Kubernetes (concretamente KEDA y Dapr), tú no tienes que tocar nada de eso.

## ¿Por qué usar Azure Container Apps?

ACA está ganando mucho tirón dentro de la plataforma Azure, y no es casualidad. Estos son algunos de sus beneficios:

| Característica | AKS | Azure Container Apps |
|----------------|-----|---------------------|
| **Gestión de infraestructura** | Tú gestionas nodos, actualizaciones, networking | Azure lo gestiona todo |
| **Escalado automático** | Necesitas configurar HPA o KEDA | Viene integrado de serie |
| **Precio** | Pagas por los nodos 24/7 | Pagas por consumo (CPU/memoria por segundo) |
| **Curva de aprendizaje** | Alta (necesitas conocer Kubernetes) | Baja (solo defines tu contenedor) |
| **Ingress/HTTPS** | Necesitas configurar Ingress Controller y certificados | Incluido automáticamente |
| **Revisiones y traffic splitting** | Configuración manual con Services | Integrado en la plataforma |
| **Almacenamiento persistente** | PersistentVolumes + PersistentVolumeClaims | Azure Files (SMB/NFS) |

> 💡 **¿Cuándo elegir ACA sobre AKS?** Cuando quieras centrarte en tu código y no en la infraestructura. Perfecto para APIs, microservicios, workers y aplicaciones web que no necesitan acceso a bajo nivel del clúster.

## Prerequisitos

Asegúrate de tener definidas las variables de entorno:

```bash
RESOURCE_GROUP="bootcamp-aca-$RANDOM"
LOCATION="spaincentral"
ENVIRONMENT_NAME="tour-of-heroes-env"
```

Crea el grupo de recursos:

```bash
az group create -n ${RESOURCE_GROUP} -l ${LOCATION}
```

# Crear el entorno de Container Apps

Lo primero que necesitas en ACA es un **Container Apps Environment**. Es como el "clúster" donde vivirán tus apps, pero sin que tengas que gestionarlo:

```bash
az containerapp env create \
-n ${ENVIRONMENT_NAME} \
-g ${RESOURCE_GROUP} \
-l ${LOCATION}
```

Esto tarda un par de minutos. Cuando termine, ya tienes tu entorno listo para desplegar contenedores 🎉

# Desplegar Tour of Heroes en ACA

Vamos a desplegar nuestra aplicación Tour of Heroes. Tiene tres componentes:

- **Base de datos**: SQL Server
- **Backend**: API en .NET
- **Frontend**: Aplicación Angular

## Configurar almacenamiento persistente con Azure Files

Aunque ACA es serverless, **sí soporta almacenamiento persistente** usando [Azure Files](https://learn.microsoft.com/es-es/azure/container-apps/storage-mounts). Esto es fundamental para nuestra base de datos SQL Server.

Primero creamos una cuenta de almacenamiento y un file share:

```bash
STORAGE_ACCOUNT_NAME="storagetoh$RANDOM"
STORAGE_SHARE_NAME="sqldata"

# Crear cuenta de almacenamiento
az storage account create \
-n ${STORAGE_ACCOUNT_NAME} \
-g ${RESOURCE_GROUP} \
-l ${LOCATION} \
--sku Standard_LRS \
--enable-large-file-share

# Crear file share para SQL Server
az storage share-rm create \
-g ${RESOURCE_GROUP} \
--storage-account ${STORAGE_ACCOUNT_NAME} \
-n ${STORAGE_SHARE_NAME} \
--quota 1024 \
--enabled-protocols SMB

# Obtener la clave de la cuenta de almacenamiento
STORAGE_ACCOUNT_KEY=$(az storage account keys list \
-n ${STORAGE_ACCOUNT_NAME} \
--query "[0].value" -o tsv)
```

Ahora vinculamos el storage al entorno de Container Apps:

```bash
STORAGE_MOUNT_NAME="sqlstorage"

az containerapp env storage set \
-n ${ENVIRONMENT_NAME} \
-g ${RESOURCE_GROUP} \
--storage-name ${STORAGE_MOUNT_NAME} \
--azure-file-account-name ${STORAGE_ACCOUNT_NAME} \
--azure-file-account-key ${STORAGE_ACCOUNT_KEY} \
--azure-file-share-name ${STORAGE_SHARE_NAME} \
--access-mode ReadWrite
```

## Desplegar SQL Server con almacenamiento persistente

Ahora desplegamos SQL Server montando el volumen de Azure Files. Para esto necesitamos usar un archivo YAML:

```bash
az containerapp create \
-n tour-of-heroes-sql \
-g ${RESOURCE_GROUP} \
--environment ${ENVIRONMENT_NAME} \
--yaml 04-cloud/00-aks/07-aca/sqlserver-app.yaml
```

Habilitamos ingress TCP interno para que las otras apps puedan conectar:

```bash
az containerapp ingress enable \
-n tour-of-heroes-sql \
-g ${RESOURCE_GROUP} \
--type internal \
--target-port 1433 \
--transport tcp
```

> 💡 **Nota**: SQL Server necesita ingress TCP interno para que la API pueda conectar mediante el nombre `tour-of-heroes-sql`.

> 🎉 **¡Listo!** Ahora SQL Server tiene almacenamiento persistente. Si el contenedor se reinicia, los datos seguirán ahí.

Guarda la cadena de conexión para el backend:

```bash
SQL_CONNECTION_STRING='Server=tour-of-heroes-sql,1433;Initial Catalog=heroes;Persist Security Info=False;User ID=sa;Password=YourStrong!Passw0rd;Encrypt=False;TrustServerCertificate=True'
```

## Desplegar el Backend (API)

Ahora desplegamos la API. Fíjate que con un solo comando tienes la app corriendo con HTTPS incluido:

```bash
az containerapp create \
-n tour-of-heroes-api \
-g ${RESOURCE_GROUP} \
--environment ${ENVIRONMENT_NAME} \
--image ghcr.io/0gis0/tour-of-heroes-dotnet-api/tour-of-heroes-api:abfb2f4 \
--cpu 0.25 \
--memory 0.5Gi \
--min-replicas 1 \
--max-replicas 10 \
--env-vars \
  ConnectionStrings__DefaultConnection="${SQL_CONNECTION_STRING}" \
  OTEL_SERVICE_NAME=tour-of-heroes-api \
--target-port 5000 \
--ingress external
```

> ⚠️ **Importante**: Usa `--ingress external` para que la API sea accesible desde Internet.

Recupera la URL de la API:

```bash
API_URL=$(az containerapp show -n tour-of-heroes-api -g ${RESOURCE_GROUP} --query properties.configuration.ingress.fqdn -o tsv)
echo "https://${API_URL}"
```

Prueba que funciona:

```bash
curl https://${API_URL}/api/hero
```

## Desplegar el Frontend

Finalmente, desplegamos el frontend pasándole la URL de la API:

```bash
az containerapp create \
-n tour-of-heroes-web \
-g ${RESOURCE_GROUP} \
--environment ${ENVIRONMENT_NAME} \
--image ghcr.io/0gis0/tour-of-heroes-angular@sha256:b1c75a464596c2b5771cd659305d80b696e940fabc2519bedb8d49b7c914644c \
--cpu 0.25 \
--memory 0.5Gi \
--min-replicas 1 \
--max-replicas 5 \
--env-vars \
  API_URL="https://${API_URL}/api/hero" \
--target-port 80 \
--ingress external
```

Obtén la URL del frontend:

```bash
WEB_URL=$(az containerapp show -n tour-of-heroes-web -g ${RESOURCE_GROUP} --query properties.configuration.ingress.fqdn -o tsv)
echo "https://${WEB_URL}"
```

¡Abre esa URL en tu navegador y ya tienes Tour of Heroes corriendo en Azure Container Apps! 🚀

# Nota sobre la base de datos

En este tutorial hemos desplegado SQL Server como contenedor con almacenamiento persistente en Azure Files. Esto nos ha permitido demostrar diferentes configuraciones de ACA:

- Uso de archivos YAML para configuraciones avanzadas
- Montaje de volúmenes persistentes con Azure Files
- Configuración de ingress TCP interno para comunicación entre contenedores

Sin embargo, **en un entorno de producción lo ideal es usar un servicio PaaS como Azure SQL Database**. Las ventajas son claras:

| SQL Server en contenedor | Azure SQL Database |
|--------------------------|-------------------|
| Tú gestionas backups | Backups automáticos |
| Sin alta disponibilidad nativa | HA incluida |
| Debes gestionar actualizaciones | Zero mantenimiento |
| Storage limitado por Azure Files | Escalado elástico |

> 🎯 **Recomendación**: Usa SQL Server en contenedor para desarrollo, demos o aprendizaje. Para producción, usa **Azure SQL Database** o **Azure SQL Managed Instance**.

# Características interesantes de ACA

## Escalado automático

ACA escala automáticamente basándose en peticiones HTTP. Puedes configurar las reglas:

```bash
az containerapp update \
-n tour-of-heroes-api \
-g ${RESOURCE_GROUP} \
--min-replicas 0 \
--max-replicas 30 \
--scale-rule-name http-scaling \
--scale-rule-type http \
--scale-rule-http-concurrency 100
```

Con `--min-replicas 0` la app puede escalar a cero cuando no hay tráfico, ¡así no pagas nada!

## Revisiones y Traffic Splitting

Cada vez que actualizas una Container App, ACA crea una nueva **revisión**. Puedes dividir el tráfico entre revisiones para hacer canary deployments:

```bash
# Ver las revisiones
az containerapp revision list -n tour-of-heroes-api -g ${RESOURCE_GROUP} -o table

# Dividir tráfico: 80% a la revisión actual, 20% a la nueva
az containerapp ingress traffic set \
-n tour-of-heroes-api \
-g ${RESOURCE_GROUP} \
--revision-weight latest=20 <nombre-revision-anterior>=80
```

## Ver logs

Para ver los logs de tu aplicación:

```bash
az containerapp logs show \
-n tour-of-heroes-api \
-g ${RESOURCE_GROUP} \
--follow
```

## Secretos

En lugar de pasar secretos como variables de entorno en texto plano, puedes usar secretos de ACA:

```bash
# Crear la app con un secreto
az containerapp create \
-n mi-app \
-g ${RESOURCE_GROUP} \
--environment ${ENVIRONMENT_NAME} \
--image mi-imagen \
--secrets "sql-conn=${SQL_CONNECTION_STRING}" \
--env-vars "ConnectionStrings__DefaultConnection=secretref:sql-conn"
```

# Comparativa de comandos: AKS vs ACA

| Acción | AKS (kubectl) | ACA (az containerapp) |
|--------|---------------|----------------------|
| Desplegar | `kubectl apply -f deployment.yaml` | `az containerapp create ...` |
| Ver pods/apps | `kubectl get pods` | `az containerapp list -g $RG` |
| Ver logs | `kubectl logs <pod>` | `az containerapp logs show` |
| Escalar | `kubectl scale deployment --replicas=5` | `az containerapp update --min-replicas 5` |
| Exponer HTTPS | Configurar Ingress + cert-manager | Automático con `--ingress external` |
| Storage persistente | PVC + StorageClass | Azure Files con `az containerapp env storage set` |

# Limpiar recursos

Cuando termines, elimina el grupo de recursos:

```bash
az group delete -n ${RESOURCE_GROUP} --yes --no-wait
```

# Resumen

1. Azure Container Apps es la opción **serverless** para ejecutar contenedores sin gestionar Kubernetes
2. Pagas por consumo (CPU/memoria por segundo), ideal para cargas variables
3. HTTPS, escalado automático y revisiones vienen de serie
4. **Sí soporta almacenamiento persistente** usando Azure Files (SMB/NFS)
5. Perfecto para APIs, microservicios y aplicaciones web

> 🎯 **Mi recomendación**: Si tu aplicación no necesita personalización avanzada del clúster, empieza con ACA. Siempre puedes migrar a AKS si lo necesitas más adelante.

## Referencias

- [Documentación oficial de Azure Container Apps](https://learn.microsoft.com/es-es/azure/container-apps/)
- [Referencia de CLI az containerapp](https://learn.microsoft.com/es-es/cli/azure/containerapp?view=azure-cli-latest)
- [Storage mounts en Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/storage-mounts)
- [Comparativa AKS vs ACA](https://learn.microsoft.com/es-es/azure/container-apps/compare-options)
