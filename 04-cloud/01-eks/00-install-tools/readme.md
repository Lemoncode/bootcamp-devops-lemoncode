# Install Tools

## Guides

Para trabajar con EKS necesitamos tener instalado en nuestros equipos las siguientes herramientas:

* kubectl 
* aws cli
* eksctl

Si bien la última herramienta no es obligatoria para trabajar con `EKS`, va a hacer todos nuestros procesos mucho más fáciles.

En el caso de `kubectl`, en el siguinete enlace podemos encontrar la [guía instalación kubectl](https://kubernetes.io/es/docs/tasks/tools/install-kubectl/).

Para instalar `aws cli`, podemos hacer uso del siguiente [enlace](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

Por último debemos instalar `eksctl`, en este [enlace](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html), tenemos los pasos necesarios.


## VsCode: DevContainers

If we can run Docker and VsCode in our system, the easiest way to set up the EKS environment is using [DevContainers](https://code.visualstudio.com/docs/devcontainers/containers).

Create `.devcontainer/devcontainer.json`

```json
// For format details, see https://aka.ms/devcontainer.json. For config options, see the
// README at: https://github.com/devcontainers/templates/tree/main/src/ubuntu
{
	"name": "Ubuntu",
	"image": "mcr.microsoft.com/devcontainers/base:jammy",
	"features": {
		"ghcr.io/devcontainers/features/aws-cli:1.1.2": {},
		"ghcr.io/CASL0/devcontainer-features/eksctl:1": {},
		"ghcr.io/devcontainers/features/kubectl-helm-minikube:1": {}
	},

	// Features to add to the dev container. More info: https://containers.dev/features.
	// "features": {},

	// Use 'forwardPorts' to make a list of ports inside the container available locally.
	// "forwardPorts": [],

	// Use 'postCreateCommand' to run commands after the container is created.
	// "postCreateCommand": "uname -a",

	// Configure tool-specific properties.
	// "customizations": {},

	// Uncomment to connect as root instead. More info: https://aka.ms/dev-containers-non-root.
	"remoteUser": "root"
}

```