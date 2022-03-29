# Incorporando el Proveedor Random

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d3.tfplan
terraform apply "d3.tfplan"
```

## Pasos

Vamos a usar el `random provider` y el recurso `random_integer`, para generar un ID único para los buckets de S3

### Paso 1. Buscar el random provider

[random provider docs](https://registry.terraform.io/providers/hashicorp/random/latest)

> EJERCICIO: Incluir el provider de tal forma que la versión que la major permanexca en 3, pero que acepte actualizaciones de la versión menor.

### Paso 2. Incorporar el Random Provider

Actualizamos `providers.tf`

```diff
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
+
+   random = {
+     source  = "hashicorp/random"
+     version = "~> 3.0"
+   }
  }
}

provider "aws" {
  region = var.aws_region
}

```

### Paso 3. Incluir en nuestra solución

> EJERCICIO: Añadir `random_integer resource` al fichero `locals.tf` en nuestra configuración, y establecer el mínimo en 10000 y el máximo en 99999. Como `name_label` usar `rand`

Actualizar `locals.tf`

```diff
+resource "random_integer" "rand" {
+ min = 10000
+ max = 99999
+}
+
locals {
  common_tags = {
    company      = var.company
    project      = "${var.company}-${var.project}"
    billing_code = var.billing_code
  }
}

```

### Clean Up

```bash
terraform destroy
```