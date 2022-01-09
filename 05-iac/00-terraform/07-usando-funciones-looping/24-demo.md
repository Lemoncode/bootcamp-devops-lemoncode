# Añadiendo prefijos al nombrado

## Pre requisitos

> Si has destruido el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d4.tfplan
terraform apply "d4.tfplan"
```

## Pasos

### Paso 1. Añadimos una nueva variable

Actualizamos `variables.tf`

```diff
+variable "naming_prefix" {
+ type        = string
+ description = "Naming prefix for all resources"
+ default     = "lemonweb"
+}
+
variable "aws_region" {
  type        = string
  description = "AWS Region to use for resources"
  default     = "eu-west-3"
}
```

### Paso 2. Manipulando el prefijo

En lugar de volcarlo directamente, vamos a añadirlo como un valor local para poderlo manipular.

Actualizamos `locals.tf`

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

  s3_bucket_name = "lc-web-app-${random_integer.rand.result}"

+ name_prefix = "${var.naming_prefix}-dev"
}

```

> EJERCICIO: `s3_bucket_name` no esta usando `naming_prefix`. Utilizarlo en lugar del valor harcoded `lc-web-app`

```diff
locals {
  common_tags = {
    company      = var.company
    project      = "${var.company}-${var.project}"
    billing_code = var.billing_code
  }

- s3_bucket_name = "lc-web-app-${random_integer.rand.result}"
+ s3_bucket_name = lower("${local.name_prefix}-${random_integer.rand.result}")

  name_prefix = "${var.naming_prefix}-dev"
}

```

### Paso 3. Añadir nombrado común a todos los recursos que lo soporten

Para ello vamos a usar la función `merge`

```bash
❯ terraform console
> merge(local.common_tags, { Name = "${local.name_prefix}-vpc" })
{
  "Name" = "globoweb-dev-vpc"
  "billing_code" = "FOO9999"
  "company" = "Globomantics"
  "project" = "Globomantics-web-app"
}
>  
```

Actualizamos `network.tf`

```diff
resource "aws_vpc" "vpc" {
  cidr_block           = var.aws_vpc_cidr_block
  enable_dns_hostnames = var.aws_vpc_enable_dns_hostnames

- tags = local.common_tags
+ tags = merge(local.common_tags, {
+   Name = "${local.name_prefix}-vpc"
+ })
}
```

Actualizamos `instances.tf`

```diff
# INSTANCES #
resource "aws_instance" "nginx" {
  count         = var.instance_count
  ami           = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type = var.aws_instance_type
  subnet_id              = aws_subnet.subnets[(count.index % var.vpc_subnet_count)].id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on             = [aws_iam_role_policy.allow_s3_all]

  user_data = templatefile("${path.module}/startup_script.tpl", {
    s3_bucket_name = aws_s3_bucket.web_bucket.id
  })

- tags = local.common_tags

+ tags = merge(local.common_tags, {
+   Name = "${local.name_prefix}-nginx-${count.index}"
+ })
+
}
```

Actualizamos `loadbalancer.tf`

```diff
## aws_elb_service_account
data "aws_elb_service_account" "root" {}

## aws_lb
resource "aws_lb" "nginx" {
- name               = "lc-web-alb"
+ name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.web_bucket.bucket
    prefix  = "alb-logs"
    enabled = true
  }

  tags = local.common_tags
}

## aws_lb_target_group
resource "aws_lb_target_group" "nginx" {
- name     = "lc-web-alb-tg"
+ name     = "${local.name_prefix}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  tags = local.common_tags
}

## aws_lb_listener
resource "aws_lb_listener" "nginx" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }

  tags = local.common_tags
}

## aws_lb_target_group_attachment
resource "aws_lb_target_group_attachment" "nginx" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.nginx.arn
  target_id        = aws_instance.nginx[count.index].id
  port             = 80
}

```

### Paso 4. Actualizar los recursos pendientes

> EJERCICIO: Investigar que recursos quedan pendientes y actualizarlos.
> TIP: Aquellos que tengan atributo name o se les pueda alimentar etiquetas.

Actualizamos `network.tf`

```diff
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

+ tags = merge(local.common_tags, {
+   Name = "${local.name_prefix}-igw"
+ })
}
```

```diff
resource "aws_subnet" "subnets" {
  count = var.vpc_subnet_count
  cidr_block              = cidrsubnet(var.aws_subnets_cidr_block, 8, count.index)
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = var.aws_subnet_map_public_ip_on_launch
  availability_zone       = data.aws_availability_zones.available.names[count.index]

- tags = local.common_tags
+ tags = merge(local.common_tags, {
+   Name = "${local.name_prefix}-subnet-${count.index}"
+ })
}
```

```diff
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.aws_route_table_cidr_block
    gateway_id = aws_internet_gateway.igw.id
  }

- tags = local.common_tags
+ tags = merge(local.common_tags, {
+   Name = "${local.name_prefix}-rtb"
+ })
}
```

```diff
resource "aws_security_group" "nginx-sg" {
- name   = "nginx_sg"
+ name   = "${local.name_prefix}-nginx_sg"
  vpc_id = aws_vpc.vpc.id

  # HTTP access from anywhere
  ingress {
    from_port = var.aws_sg_ingress_port
    to_port  = var.aws_sg_ingress_port
    protocol = "tcp"
    cidr_blocks = [var.aws_vpc_cidr_block]
  }

  # outbound internet access
  egress {
    from_port = var.aws_sg_egress_port
    to_port  = var.aws_sg_egress_port
    protocol = "-1"
    cidr_blocks = var.aws_sg_egress_cidr_blocks
  }

  tags = local.common_tags
}
```


```diff
resource "aws_security_group" "alb_sg" {
- name   = "nginx_alb_sg"
+ name   = "${local.name_prefix}-nginx_alb_sg"
  vpc_id = aws_vpc.vpc.id

  # HTTP access from anywhere
  ingress {
    from_port = var.aws_sg_ingress_port
    to_port  = var.aws_sg_ingress_port
    protocol = "tcp"
    cidr_blocks = var.aws_sg_ingress_cidr_blocks
  }

  # outbound internet access
  egress {
    from_port = var.aws_sg_egress_port
    to_port  = var.aws_sg_egress_port
    protocol = "-1"
    cidr_blocks = var.aws_sg_egress_cidr_blocks
  }

  tags = local.common_tags
}
```

## Clean Up

```bash
terraform destroy
```