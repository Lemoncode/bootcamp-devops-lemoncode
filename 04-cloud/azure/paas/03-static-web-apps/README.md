# Azure Static Web Apps

Si lo que tienes es una aplicación web estática, es decir, una aplicación web que no tiene ningún tipo de lógica de negocio en el lado del servidor, puedes desplegarla en [Azure Static Web Apps](https://docs.microsoft.com/es-es/azure/static-web-apps/overview).

Para poder desplegar el frontal de Tour of heroes lo primero que necesitas hacer es un fork de mi repositorio: [https://github.com/0GiS0/tour-of-heroes-angular](https://github.com/0GiS0/tour-of-heroes-angular) ya que al lanzar el comando que despliegue la aplicación este inyectará un flujo de GitHub Actions en el mismo para poder desplegarlo en Azure Static Web Apps.

Como en el resto de los servicios, lo primero que vamos a hacer es cargar algunas variables de entorno:

```bash
# Static Web App variables
WEB_APP_NAME="tour-of-heroes-web"
GITHUB_USER_NAME="<your-github-user-name>"
```

o si estás en Windows:

```pwsh
# Static Web App variables
$WEB_APP_NAME="tour-of-heroes-web"
$GITHUB_USER_NAME="<your-github-user-name>"
```

## Crear el servicio de Azure Static Web Apps

Para crear el servicio de Azure Static Web Apps, ejecuta el siguiente comando:

```bash
echo -e "Create Azure Static Web App 🚀"

az staticwebapp create \
--name $WEB_APP_NAME \
--resource-group $RESOURCE_GROUP \
--source https://github.com/$GITHUB_USER_NAME/tour-of-heroes-angular \
--location "westeurope" \
--branch main \
--app-location "/" \
--output-location "dist/angular-tour-of-heroes" \
--login-with-github
```

o si estás en Windows:

```pwsh
echo -e "Create Azure Static Web App 🚀"

az staticwebapp create `
--name $WEB_APP_NAME `
--resource-group $RESOURCE_GROUP `
--source https://github.com/$GITHUB_USER_NAME/tour-of-heroes-angular `
--location "westeurope" `
--branch main `
--app-location "/" `
--output-location "dist/angular-tour-of-heroes" `
--login-with-github
```

El resto de servicios se han desplegado en la región `uksouth`, pero en este caso, como no hay disponibilidad de Azure Static Web Apps en esa región, lo he desplegado en `westeurope`.

¡Y ya está! Con esto ya tienes desplegada la aplicación Tour Of Heroes en servicios PaaS de Azure. Si quisieras eliminar todo lo creado hasta ahora es tan sencillo como ejecutar el siguiente comando:

```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

Happy coding! 🥸