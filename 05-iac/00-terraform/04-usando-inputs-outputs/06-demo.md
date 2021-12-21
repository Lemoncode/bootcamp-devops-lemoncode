# Desplegando la Configuración Actualizada

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d1.tfplan
terraform apply "d1.tfplan"
```

## Pasos

### Paso 1. Alimentar valores no establecidos por defecto

Vamos a alimentar las siguientes variables:

* aws_access_key
* aws_secret_key
* project
* billing_code

Por ejemplo, si las queremos alimentar desde la consola:

```bash
terraform plan -var=billing_code="FOO9999" -var=project="web-app" -var=aws_access_key="YOUR_ACCESS_KEY" -var=aws_secret_key="YOUR_SECRET_KEY" -out d2.tfplan
```

Cómo podemos observar este comando puede ser muy extenso. Ua mejor forma es creando un fichero `tfvars`

Crear `lab/lc_web_app/terraform.tfvars`

```tfvars
billing_code = "FOO9999"
project      = "web-app"

```

Lo siguiente, son los valores realcionados con las credneciales, estas no las queremos en un fichero, así que las vamos a alimentar como variables de entorno:

```bash
export TF_VAR_aws_access_key="YOUR_ACCESS_KEY"
export TF_VAR_aws_secret_key="YOUR_SECRET_KEY"
```

Ahora podemos ejecutar plan sin ser tan verbosos en la línea de comandos:

```bash
terraform plan -out d2.tfplan
```

Si no hemos recreado nuestra configuración, veremos una salida similar a la siguiente:

```bash
Plan: 0 to add, 6 to change, 0 to destroy.

Changes to Outputs:
  + aws_instance_public_dns = "ec2-13-38-33-113.eu-west-3.compute.amazonaws.com"

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: d2.tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "d2.tfplan"
``` 


Aplicamos la nueva configuración

```bash
terraform apply "d2.tfplan"
```

Para ver los que hemos aplicado

```bash
terraform show
```

Para recuperar los outputs podemos usar:

```bash
terraform output
```

## Clean Up

```bash
terraform destroy
```