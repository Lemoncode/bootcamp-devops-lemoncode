# Create AWS user

## Pre requisitos

* Tener una cuenta de `AWS` y poder acceder a la consola de `AWS` vía web.
* `AWS CLI` instalado en nuestro equipo.

## Agenda


## Introducción

Cuando creamos una nueva cuenta en AWS, el usuario por defecto es `root`, se considera como buena práctica no utilizar este usuario para realizar las distaintas tareas en su día a día. En su lugar es mejor, crear un nuevo usario, con permisos de administrador y guardar las clavers de `root` en un lugar bien seguro. 

Para poder crear un usuario con permisos de administrador previamente debemos crear un grupo y a este grupo añadir las poíticas de `AWS`, de administrador.

## Creando un grupo

```bash
aws iam create-group --group-name <group-name>
```

> Contsraits: The name can consist of letters, digits, and the following characters: plus (+), equal (=), comma (,), period (.), at (@), underscore (_), and hyphen (-). The name is not case sensitive and can be a maximum of 128 characters in length.

Para verificar que hemos tenido exito en nuestra operación

```bash
aws iam list-groups
```

La respuesta incluye el `Amazon Resource Name` (ARN) para el nuevo grupo. El `ARN` es un standard  que Amazon utiliza para identificar recursos.

## Atando una política al grupo

Utilizando el siguiente comando enlazamos la política de administardor con el grupo recientemenet creado 

```bash
aws iam attach-group-policy --group-name <group-name> --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
``` 

Para verificar que la política se ha atado correctamente al grupo 

```bash
aws iam list-attached-group-policies --group-name <group-name>
``` 

La respuesta nos da la lista de políticas atadas al grupo. Si queremos comprobar los contenidos de una política en particular podemos usar `aws iam get-policy`

## Creando un usuario IAM y añadiendolo al grupo

### 1. Creamos un usuario

```bash
aws iam create-user --user-name eksAdmin
```

### 2. Añadiendo el Usuaro a un grupo

```bash
aws iam add-user-to-group --group-name <group-name>  --user-name <user-name>
``` 


### 3. (Opcional) Dar al usuario acceso a la consola.

Tenemos que proporcioanr al usuario la url de su cuenta para que se pueda registrar dentro de la consola

```
https://My_AWS_Account_ID.signin.aws.amazon.com/console/
```

```bash
aws iam create-login-profile --generate-cli-skeleton > create-login-profile.json
```

Genera un `template`, que ahora podemos utilizar para inicializar el usuario

```bash
aws iam create-login-profile --cli-input-json file://create-login-profile.json
``` 

Esto nos da como salida

```json
{
  "LoginProfile": {
      "UserName": "eksAdmin",
      "CreateDate": "2020-12-20T16:38:19+00:00",
      "PasswordResetRequired": true
  }
}
```

Ahora con el `loginProfile` creado, del ARN del usuario extraemos su `Account ID` , solo los dígitos, y lo pegamos aquí:

```
google https://xxxxxxxxxxxx.signin.aws.amazon.com/console/
``` 

### 4. Crear Access Key

Con esta `key` nuestro nuevo usuario tendrá acceso programático desde `AWS CLI`

```bash
aws iam create-access-key --user-name <user-name>
``` 

Con la salida anterior podemos configurar nuestro usurio por defecto usando `aws configute`

En el caso de Linux y macOS, podemos encontrar nuestras credenciales en `/.aws`

## Referencias

> Configurar AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html