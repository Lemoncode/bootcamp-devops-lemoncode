# Actualizando Network y la Configuración de Instancia

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d2.tfplan
terraform apply "d2.tfplan"
```

## Pasos

Ahora que hemos añadido la fuente de datos de las `avaibility zones`, vamos a actualizar los `security groups` relacionados con las `subnets` y las instancias EC2.

## Paso 1. Preparandos para la nueva subnet

Actualizamos `network.tf`

```diff
resource "aws_subnet" "subnet1" {
  cidr_block              = var.subnet_cidr_block
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = var.subnet_map_public_ip_on_launch
+ availability_zone       = data.aws_availability_zones.available.names[0]

  tags = local.common_tags
}
```

Antes que creemos la segunda `availability zone`, recordemos que hemos definido el `cidr block` en un variable, sería mejor si tuvieramos un sólo lugar donde definir los `cidr blocks` de ambas.

Actualizamos `variables.tf`

```diff
# ....
-variable "subnet_cidr_block" {
-  type        = string
-  description = "Subnet cidr block"
-  default     = "10.0.0.0/24"
-}
+
+variable "subnets_cidr_block" {
+  type        = list(string)
+  description = "Subnet cidr block"
+  default     = ["10.0.0.0/24", "10.0.1.0/24"]
+}
# ....
```

Ahora podemos actualizar la subnet de la siguienete manera:

Actualizamos `network.tf`

```diff
# ....
resource "aws_subnet" "subnet1" {
- cidr_block              = var.subnet_cidr_block
+ cidr_block              = var.subents_cidr_block[0]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = var.subnet_map_public_ip_on_launch
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = local.common_tags
}
# ....
```

### Paso 2. Añadimos la nueva subnet

Actualizamos `network.tf`

```diff
resource "aws_subnet" "subnet1" {
  cidr_block              = var.subents_cidr_block[0]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = var.subnet_map_public_ip_on_launch
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = local.common_tags
}
+
+resource "aws_subnet" "subnet2" {
+ cidr_block              = var.subents_cidr_block[1]
+ vpc_id                  = aws_vpc.vpc.id
+ map_public_ip_on_launch = var.subnet_map_public_ip_on_launch
+ availability_zone       = data.aws_availability_zones.available.names[1]
+
+ tags = local.common_tags
+}
```

### Paso 3. Actualizando las route tables

Ahora que hemos generado una nueva subnet, debemos crear una nueva asociación con la `route table` a fin de poder redirigir el tráfico desde la nueva EC2 hacia el exterior.

```diff
# ....
resource "aws_route_table_association" "rta-subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rtb.id
}
+
+resource "aws_route_table_association" "rta-subnet2" {
+ subnet_id      = aws_subnet.subnet2.id
+ route_table_id = aws_route_table.rtb.id
+}
# ....
```

### Paso 4. Creamos una nueva instancia EC2

Actualizamo `instances.tf`

```ini
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

  tags = local.common_tags

}

#-----------diff-------------#
resource "aws_instance" "nginx2" {
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Lemon Land Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">Welcome to &#127819; land</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF

  tags = local.common_tags

}
#-----------diff-------------#
```

### Paso 5. Añadir un security group

Necesitamos crear un `security group` adicional para el balanceador de carga, de manera que permita el tráfico al puerto 80 desde cualquier dirección. Simplemente vamos a duplicar el que ya tenemos:

Actualizamos `network.tf`

```ini
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

  tags = local.common_tags
}
#-----------diff-------------#
resource "aws_security_group" "alb_sg" {
  name   = "nginx_alb_sg"
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

  tags = local.common_tags
}
#-----------diff-------------#
```

Ahora que vamos a tener un load balancer por delante de nuestras instancias, sólo queremos aceptar táfico que venga desde dentro de la `VPC`

Actualizamos `network.tf`

```diff

# SECURITY GROUPS #
resource "aws_security_group" "nginx-sg" {
  name   = "nginx_sg"
  vpc_id = aws_vpc.vpc.id

  # HTTP access from anywhere
  ingress {
    from_port = var.sg_ingress_port
    to_port   = var.sg_ingress_port
    protocol  = "tcp"
-   cidr_blocks = var.sg_ingress_cidr_blocks
+   cidr_blocks = [var.vpc_cidr_block]
  }

```


## Clean Up

```bash
terraform destroy
```