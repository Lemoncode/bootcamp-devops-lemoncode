# Añadiendo variables a la configuración

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
terraform plan -out d1.tfplan
terraform apply "d1.tfplan"
```

## Pasos

### Paso 1. Crear un fichero de variables

Crear `./lab/globo_web_app/variables.tf`.

```tf
# variables.tf
variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
  sensitive   = true
}
```

## Clean Up

```bash
terraform destroy
```