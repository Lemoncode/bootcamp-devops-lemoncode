# Añadiendo Outputs a la Configuración

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d1.tfplan
terraform apply "d1.tfplan"
```

Creamos `./lab/lc_web_app/outputs.tf`

```ini
output "aws_instance_public_dns" {

}
```

Para la entrada tomamos el valor expuesto por la instacia en `main.tf`

```ini
resource "aws_instance" "nginx1" {
```

Actualizamos `outputs.tf`

```diff
output "aws_instance_public_dns" {
+ value = aws_instance.nginx1.public_dns
}
```

## Clean Up

```bash
terraform destroy
```