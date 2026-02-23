# Añadiendo Locals a la Configuración

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d1.tfplan
terraform apply "d1.tfplan"
```

## Pasos

### Paso 1. Crear un nuevo fichero para Locals

Crear `./lab/lc_web_app/locals.tf`.

```ini
locals {
  common_tags = {
    
  }
}

```

### Paso 2. Añadiendo valores

Queremos añadir 3 valores, `company`, `project` y `billing_code`. Vamos a sacar esta información de las `variables`

Actualizamos `variables.tf`

```ini
# ....
# COMMON
variable "company" {
  type        = string
  description = "Company name for resource tagging"
  default     = "Lemoncode"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
}

variable "billing_code" {
  type        = string
  description = "Billing  code for resource tagging"
}

```

Ahora podemos actualizar `locals.tf`

```diff
locals {
  common_tags = {
+   company      = var.company
+   project      = "${var.company}-${var.project}"
+   billing_code = var.billing_code
  }
}
```

### Paso 4. Actualizando nuestra configuración

Ahora podemos actualizar nuestra configuración con las etiquetas.

Actualizamos `main.tf`

```diff
# PROVIDERS
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

# DATA
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# RESOURCES

# NETWORKING #
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.vpc_enable_dns_hostnames

+ tags = local.common_tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

+ tags = local.common_tags
}

resource "aws_subnet" "subnet1" {
  cidr_block              = var.subnet_cidr_block
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = var.subnet_map_public_ip_on_launch

+ tags = local.common_tags
}

# ROUTING #
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.route_table_cidr_block
    gateway_id = aws_internet_gateway.igw.id
  }

+ tags = local.common_tags
}

resource "aws_route_table_association" "rta-subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rtb.id
}

# SECURITY GROUPS #
resource "aws_security_group" "nginx-sg" {
  name   = "nginx_sg"
  vpc_id = aws_vpc.vpc.id

  # HTTP access from anywhere
  ingress {
    from_port   = var.sg_ingress_port
    to_port     = var.sg_ingress_port
    protocol    = "tcp"
    cidr_blocks = var.sg_ingress_cidr_blocks
  }

  # outbound internet access
  egress {
    from_port   = var.sg_egress_port
    to_port     = var.sg_egress_port
    protocol    = "-1"
    cidr_blocks = var.sg_egress_cidr_blocks
  }

+ tags = local.common_tags
}

# INSTANCES #
resource "aws_instance" "nginx1" {
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Lemon Land Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">Welcome to &#127819; land</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF

+ tags = local.common_tags

}

```

El `map` de locals `common_tags` será evaluado contra la etiqueta `tags`, la cual espera un tipo de dato `map`.

## Clean Up

```bash
terraform destroy
```