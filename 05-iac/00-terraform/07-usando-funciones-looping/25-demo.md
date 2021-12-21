# Desplegando la configuración actualizada

## Pre requisitos

> Si has destruido el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d4.tfplan
terraform apply "d4.tfplan"
```

## Pasos

### Paso 1.

```bash
terraform fmt
```

### Paso 2.

```bash
terraform validate
```

Obtenemos los siguientes errores:

```bash
╷
│ Error: Reference to undeclared resource
│ 
│   on loadbalancer.tf line 11, in resource "aws_lb" "nginx":
│   11:   subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
│ 
│ A managed resource "aws_subnet" "subnet1" has not been declared in the root module.
╵
╷
│ Error: Reference to undeclared resource
│ 
│   on loadbalancer.tf line 11, in resource "aws_lb" "nginx":
│   11:   subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
│ 
│ A managed resource "aws_subnet" "subnet2" has not been declared in the root module.
╵

```

Notar que en `loadbalancer.tf` estamos referenciando recursos que ya no existen.

Actualizamos `loadbalancer.tf`

```diff
resource "aws_lb" "nginx" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
- subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
+ subnets = aws_subnet.subnets[*].id

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.web_bucket.bucket
    prefix  = "alb-logs"
    enabled = true
  }

  tags = local.common_tags
}
```

Ejecutamos de nuevo `terraform validate`

```bash
terraform validate
Success! The configuration is valid.
```

### Paso 3.

Exportamos las credenciales

```bash
export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_ACCESS_KEY
```

### Paso 4.

Planificamos y aplicamos

```bash
terraform plan -out d5.tfplan
```

Obtenemos algo similar a esto:

```bash
Plan: 16 to add, 4 to change, 16 to destroy.

Changes to Outputs:
  ~ aws_instance_public_dns = "lc-web-alb-73418185.eu-west-3.elb.amazonaws.com" -> (known after apply)

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: d5.tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "d5.tfplan"
```

Desplegamos

```bash
terraform apply "d5.tfplan"
```

## Clean Up

```bash
terraform destroy
```