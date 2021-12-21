# Especificando Required Providers

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d3.tfplan
terraform apply "d3.tfplan"
```

## Pasos

### Paso 1. Visitando la documentación

Antes de incorporar `terraform` y el bloque `required_providers` a nuestra configuración, vamos a ver la documentación.

* [Official Docs](https://registry.terraform.io/) -> `Browse - Providers` --> `Select AWS` --> `Documentation tab`

Aquí podemos encontrar un [ejemplo de uso del provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Paso 2. Creamos el fichero para providers

Creamos el fichero `./lab/lc_web_app/providers.tf`

```tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

```

### Paso 3. Actualizando el paso de credenciales

Si nos fijamos en la documentación, podemos encontrar una sección a la derecha [Authentication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication)

Aquí podemos ver las distintas opciones que soporta el provider para autentificarnos.

Actualizamos `variables.tf`

```diff
# PROVIDER
- variable "aws_access_key" {
-   type        = string
-   description = "AWS Access Key"
-   sensitive   = true
- }
-
- variable "aws_secret_key" {
-   type        = string
-   description = "AWS Secret Key"
-   sensitive   = true
- }
```

### Paso 4. Eliminando la configuración previa del Provider

Nuestro provider está definido en `network.tf`, vamos a quitarlo de aquí.

Actualizamos `network.tf`

```diff
-# PROVIDERS
- provider "aws" {
-   access_key = var.aws_access_key
-   secret_key = var.aws_secret_key
-   region     = var.aws_region
- }

```

Actualizamos `providers.tf`

```diff
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
+
+provider "aws" {
+ region = var.aws_region
+}
+
```

## Clean Up

```bash
terraform destroy
```