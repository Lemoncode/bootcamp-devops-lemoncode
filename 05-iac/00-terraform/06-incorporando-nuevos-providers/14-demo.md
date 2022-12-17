# Esqueleto recursos IAM y S3

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d3.tfplan
terraform apply "d3.tfplan"
```

## Pasos

### Paso 1. Configuración S3

Crear `lab/lc_web_app/s3.tf`

```tf
# aws_s3_bucket

# aws_s3_bucket_acl

# aws_s3_bucket_policy

# aws_iam_role

# aws_iam_role_policy

# aws_iam_instance_profile
```

### Paso 2. Configuración load balancer

Actualizamos `loadbalancer.tf`

```diff
+## aws_elb_service_account
+
## aws_lb
resource "aws_lb" "nginx" {
```

### Paso 3. Incluir los recursos del bucket

Los ficheros que va a servir el bucket los podemos encontrar en la carpeta `.website`, compiamos dentro de `lab/lc_web_app` la carpeta.

```bash
# From root solution
cp -r .website/ ./lab/lc_web_app
mv ./lab/lc_web_app/.website ./lab/lc_web_app/website
```

### Paso 4. Generar el nombre random S3

Actualizar `locals.tf`

```diff
resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

locals {
  common_tags = {
    company      = var.company
    project      = "${var.company}-${var.project}"
    billing_code = var.billing_code
  }

+ s3_bucket_name = "lc-web-app-${random_integer.rand.result}"
}

```

## Clean Up

```bash
terraform destroy
```