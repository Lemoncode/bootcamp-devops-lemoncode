## Instalando Terraform

La instalación de Terraform es un simple ejecutable que añadiremos a nuestro path. Podemos usar los gestores de paquetes de nuestro sistema operativo para instalarlo.

## Instalación Manual

Este paso es común a todos los sistemas operativos.

Descargar el paquete adecuado para nuestro sistema operativo en [este enlace](https://www.terraform.io/downloads).

### Instalación Manual Mac o Linux

Una vez descargado lo descomprimimos, y lo movemos al directorio de ejectutables.

```bash
mv ~/Downloads/terraform /usr/local/bin/
```

Para confirmar la instalación, simplemente ejecutar:

```bash
terraform -help
```

### Instalación Manual Windows

Una vez descargado lo descomprimimos y lo ubicamos en una carpeta fácilmente reconocible por ejemplo `C:\terraform`. 

Para editar el `PATH`, seguiremos los siguientes pasos:

1. Ir a `Control panel` --> `System` --> `System settings` --> `Environment Variables`
2. Buscar `PATH`
3. Pulsar `edit` y modificarlo de forma adecuada
4. Asegurar que hemos incluido `;` --> `c:\path;c:\path2`

## Visual Studio Code Devconatiners

Crear en el raíz del proyecto el directorio `.devcontainer`, dentro de este directorio añadimos el fichero `devcontainer.json`

```json
// For format details, see https://aka.ms/devcontainer.json. For config options, see the
// README at: https://github.com/devcontainers/templates/tree/main/src/ubuntu
{
	"name": "Ubuntu",
	"image": "mcr.microsoft.com/devcontainers/base:jammy",
	"features": {
		"ghcr.io/devcontainers/features/aws-cli:1": {},
		"ghcr.io/devcontainers/features/terraform:1": {}
	}

	// Features to add to the dev container. More info: https://containers.dev/features.
	// "features": {},

	// Use 'forwardPorts' to make a list of ports inside the container available locally.
	// "forwardPorts": [],

	// Use 'postCreateCommand' to run commands after the container is created.
	// "postCreateCommand": "uname -a",

	// Configure tool-specific properties.
	// "customizations": {},

	// Uncomment to connect as root instead. More info: https://aka.ms/dev-containers-non-root.
	// "remoteUser": "root"
}

```

Ahora sólo tenemos que reabrir el directorio utilizando la opción de `Devcontainers` y tendremos el entorno preparado para trabajar con `Terraform` y `AWS`

## Referencias

[Terraform Downloads](https://www.terraform.io/downloads)
[Where can I set up path xxxx.exe on Windows?](https://stackoverflow.com/questions/1618280/where-can-i-set-path-to-make-exe-on-windows)