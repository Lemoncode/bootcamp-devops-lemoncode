# Usando la función cidrsubnet

## Pre requisitos

> Si has destruido el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d4.tfplan
terraform apply "d4.tfplan"
```

## Pasos

### Paso 1. Utilizando cidrsubnet

Actualizamos `network.tf`

```diff
resource "aws_subnet" "subnets" {
  count = var.vpc_subnet_count
- cidr_block              = var.subnets_cidr_block[count.index]
+ cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = var.subnet_map_public_ip_on_launch
  availability_zone       = data.aws_availability_zones.available.names[count.index]
}

```

### Paso 2. Actualizar las instancias

Abrimos `instances.tf`

> EJERCICIO: Hacer la elección de subnet ciclica para repartir las instancias de manera equitativa entre las diferentes subnets.

```diff
# INSTANCES #
resource "aws_instance" "nginx" {
  count         = var.instance_count
  ami           = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type = var.aws_instance_type
- subnet_id              = aws_subnet.subnets[count.index].id
+ subnet_id              = aws_subnet.subnets[(count.index % var.vpc_subnet_count)].id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on = [
    aws_iam_role_policy.allow_s3_all
  ]

  user_data = templatefile("${path.module}/startup_script.tpl", {
    s3_bucket_name = aws_s3_bucket.web_bucket.id
  })

  tags = local.common_tags

}

```


## Clean Up

```bash
terraform destroy
```