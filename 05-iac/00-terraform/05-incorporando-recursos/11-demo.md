# Desplegando la Arquitectura Actualizada

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d2.tfplan
terraform apply "d2.tfplan"
```

## Pasos

### Paso 1. Validar nuestra configuración

```bash
terraform validate
```

Si lo ejecutamos, obtenemos el siguiente `error`

```bash
╷
│ Error: Invalid default value for variable
│ 
│   on variables.tf line 42, in variable "subnets_cidr_block":
│   42:   default     = ["10.0.0.0/24", "10.0.1.0/24"]
│ 
│ This default value is not compatible with the variable's type constraint: string required.
╵

```

Básicamente hemos olvidado actualizar el tipo de la variable, actualizamos `variables.tf`

```diff
variable "subnets_cidr_block" {
- type        = string
+ type        = list(string)
  description = "Subnet cidr block"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}
```

Volvemos a validar

```bash
terraform validate
```

Obtenemos ahora el siguiente resultado:

```bash
╷
│ Error: only alphanumeric characters and hyphens allowed in "name"
│ 
│   with aws_lb_target_group.nginx,
│   on loadbalancer.tf line 17, in resource "aws_lb_target_group" "nginx":
│   17:   name     = "lc_web_alb_tg"
│ 
╵
╷
│ Error: Reference to undeclared input variable
│ 
│   on network.tf line 34, in resource "aws_subnet" "subnet1":
│   34:   cidr_block              = var.subents_cidr_block[0]
│ 
│ An input variable with the name "subents_cidr_block" has not been declared. Did you mean "subnets_cidr_block"?
╵
╷
│ Error: Reference to undeclared input variable
│ 
│   on network.tf line 43, in resource "aws_subnet" "subnet2":
│   43:   cidr_block              = var.subents_cidr_block[1]
│ 
│ An input variable with the name "subents_cidr_block" has not been declared. Did you mean "subnets_cidr_block"?
```

El primer error está relacionado con el nombre del recurso, sólo soporta guiones.

Actualizamos `loadbalancer.tf`

```diff
## aws_lb
resource "aws_lb" "nginx" {
- name               = "lc_web_alb"
+ name               = "lc-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  enable_deletion_protection = false

  tags = local.common_tags
}
```

Los dos siguientes tienen que ver con `typos`

Actualizamos `network.tf`

```diff
resource "aws_subnet" "subnet1" {
- cidr_block              = var.subents_cidr_block[0]
+ cidr_block              = var.subnets_cidr_block[0]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = var.subnet_map_public_ip_on_launch
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = local.common_tags
}

resource "aws_subnet" "subnet2" {
- cidr_block              = var.subents_cidr_block[1]
+ cidr_block              = var.subnets_cidr_block[1]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = var.subnet_map_public_ip_on_launch
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = local.common_tags
}

```

Volvemos a validar

```bash
terraform validate
```

Obtenemos un nuevo error:

```bash
╷
│ Error: only alphanumeric characters and hyphens allowed in "name"
│ 
│   with aws_lb_target_group.nginx,
│   on loadbalancer.tf line 18, in resource "aws_lb_target_group" "nginx":
│   18:   name     = "lc_web_alb_tg"
│ 
╵
```

De nuevo el error del nombrado, sólo se soportan guiones.

Actualizamos `loadbalancer.tf`

```diff
# ....
## aws_lb_target_group
resource "aws_lb_target_group" "nginx" {
- name     = "lc_web_alb_tg"
+ name     = "lc-web-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  tags = local.common_tags
}

```

### Paso 2. Crear el plan

Ahora estamos listos, para generar el `plan`, pero antes registrar las credenciales, si no están registradas en la terminal:

```bash
export TF_VAR_aws_access_key=YOUR_ACCESS_KEY
export TF_VAR_aws_secret_key=YOUR_SECRET_KEY
```

```bash
terraform plan -out d3.tfplan
```

Obtenemos algo similar a esto:

> Si hemos destruido y recreado el entorno la salida serán todo adiciones.

```bash
Plan: 12 to add, 1 to change, 3 to destroy.

Changes to Outputs:
  ~ aws_instance_public_dns = "ec2-13-38-33-113.eu-west-3.compute.amazonaws.com" -> (known after apply)

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: d3.tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "d3.tfplan"
```

Si intentamos alcanzar el dns público `ec2-13-38-33-113.eu-west-3.compute.amazonaws.com`, nos dará un error, ahora está detrás del balanceador de carga.

Actualizamos `outputs.tf`

```diff
output "aws_instance_public_dns" {
- value = aws_instance.nginx1.public_dns
+ value = aws_lb.nginx.dns_name
}
```

Validamos de nuevo

```bash
terraform validate
```

Y ahora porque, no hemos hecho ningún cambio a los recursos, simplemente podemos ejecutar `terraform apply` directamente, con el flag `-auto-approve`

Ahora obtenemos como `output` algo parecido a esto:

```bash
Outputs:

aws_instance_public_dns = "lc-web-alb-73418185.eu-west-3.elb.amazonaws.com"
```

> NOTA: El comando que acabamos de lanzar tiene fines demostrativos. En nuestro día a día, no lanzar nunca este comando a menos que se tenga la certeza de que no estamos impactando en los recursos de nuestro entorno.

### Clean Up

```bash
terraform destroy
```