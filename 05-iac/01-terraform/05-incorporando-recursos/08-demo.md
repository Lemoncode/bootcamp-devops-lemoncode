# Añadiendo availability zones

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d2.tfplan
terraform apply "d2.tfplan"
```

## Pasos

### Paso 1. Navegando en la documentación

Navegamos a la documentación oficial [registry.terraform.io](https://registry.terraform.io/) 

Aquí seleccionamos los `providers`, dentro de los providers, encontraremos `AWS`.

Veremos ahora dos tabs: `Overview` y `Documentation`, selecionar `Documentation`.

A la izquierda tenemos un buscador, comenzar a escribir `availability`, veremos como filtra en tiempo real, la entrada que estamos buscando es [aws_availability_zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones)


### Paso 2. Actualizar nuestro código

Actualizar `network.tf`

```diff
# ....
# DATA
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
+
+data "aws_availability_zones" "available" {
+  state = "available"
+}
+
# ....
```

## Clean Up

```bash
terraform destroy
```