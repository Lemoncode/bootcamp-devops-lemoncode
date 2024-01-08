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

Cuando este comando termine de ejecutarse lo que va a ocurrir es que se habrá creado un workflow de GitHub Actions en el repositorio que le pasé como valor del parámetro `--source` y que se encargará de desplegar la aplicación en Azure Static Web Apps. Puedes ver el progreso en tu repo:

<img src="../images/Workflow de GitHub Actions para desplegar el frontal de tour of heroes.png" width="800">

Para recuperar la URL de esta aplicación lanza lo siguiente:

```bash
WEBAPP_URL=$(az staticwebapp show \
--name $WEB_APP_NAME \
--resource-group $RESOURCE_GROUP \
--query "defaultHostname" \
--output tsv)

echo "Static Web App deployed 🚀"
echo "Static Web App URL: https://$WEBAPP_URL"
```

o si estás en Windows:

```pwsh
$WEBAPP_URL=$(az staticwebapp show `
--name $WEB_APP_NAME `
--resource-group $RESOURCE_GROUP `
--query "defaultHostname" `
--output tsv)

echo "Static Web App deployed 🚀"
echo "Static Web App URL: https://$WEBAPP_URL"
```

Aunque verás que la aplicación se está ejecutando la misma no está apuntando a la API correcta. En este ejemplo tenemos que modificar el flujo de GitHub Actions para que pueda llamar a otro script dentro de mi package.json. Por lo que abre el mismo desde Github y modifica el paso Build and Deploy con lo siguiente:

```yaml
      - name: Build And Deploy
        id: builddeploy
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN_WONDERFUL_BAY_0AF2E3F03 }}
          repo_token: ${{ secrets.GITHUB_TOKEN }} # Used for Github integrations (i.e. PR comments)
          action: "upload"
          ###### Repository/Build Configurations - These values can be configured to match your app requirements. ######
          # For more information regarding Static Web App workflow configurations, please visit: https://aka.ms/swaworkflowconfig
          app_build_command: API_URL=${{ secrets.API_URL}} npm run build-with-api-url
          app_location: "/" # App source code path
          api_location: "" # Api source code path - optional
          output_location: "dist/angular-tour-of-heroes" # Built app content directory - optional
          ###### End of Repository/Build Configurations ######
```

Lo único que he hecho ha sido añadir la propiedad llamada **app_build_command** y le he pasado el valor `API_URL=${{ secrets.API_URL}} npm run build-with-api-url`. Esto lo que hace es que cuando se ejecute el comando `npm run build-with-api-url` se le pasará la variable de entorno `API_URL` con el valor que le hemos pasado en el secreto `API_URL`.

>Cuidado: No copies y pegues el código anterior, ya que el secreto `AZURE_STATIC_WEB_APPS_API_TOKEN_WONDERFUL_BAY_0AF2E3F03` es un secreto que se ha generado especificamente para tu Azure Static Web App. Solamente añade la propiedad **app_build_command**. También tienes que tener un secreto llamado **API_URL** con el valor de la URL de tu API.

¡Y ya está! Con esto ya tienes desplegada la aplicación Tour Of Heroes en servicios PaaS de Azure. Si quisieras eliminar todo lo creado hasta ahora es tan sencillo como ejecutar el siguiente comando:

```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

Happy coding! 🥸