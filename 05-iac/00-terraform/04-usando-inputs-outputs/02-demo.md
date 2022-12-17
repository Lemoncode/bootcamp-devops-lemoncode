# Añadiendo variables a la configuración

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d1.tfplan
terraform apply "d1.tfplan"
```

## Pasos

### Paso 1. Crear un fichero de variables e inncluir las credenciales como variables

Crear `./lab/lc_web_app/variables.tf`.

```ini
# variables.tf
variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
  sensitive   = true
}
```

Ahora podemos actualizar `main.tf`

```diff
provider "aws" {
+ access_key = var.aws_access_key
  secret_key = "UTsppKB0IGfTVVWi9PVtSe8USNbvc07JgyNtAijh"
  region     = "eu-west-3"
}
```

Hagamos lo mismo con el secreto de AWS, actualizamos `main.tf`

```diff
variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
  sensitive   = true
}
+
+variable "aws_secret_key" {
+ type        = string
+ description = "AWS Secret Key"
+ sensitive   = true
+}
+
```

Actualizamos `main.tf`

```diff
provider "aws" {
  access_key = var.aws_access_key
+ secret_key = var.aws_secret_key
  region     = "eu-west-3"
}
```

### Paso 2. Incluimos la región

Actualizamos `variables.tf`

```diff
# ....
+
+variable "aws_region" {
+ type        = string
+ description = "AWS Region to use for resources"
+ default     = "eu-west-3"
+}
```

Actualizamos `main.tf`

```diff
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
+ region     = var.aws_region
}
```

### Paso 3. Actualizar Networking

Vamos a crear nuevas entradas en `variables.tf` para los recursos de Networking. 

```ini
# ....
# NETWORKING
variable "vpc_cidr_block" {
  type        = string
  description = "VPC cidr block"
  default     = "10.0.0.0/16"
}

variable "vpc_enable_dns_hostnames" {
  type        = bool
  description = "Enable / Disable DNS hostnames on VPC"
  default     = true
}

variable "subnet_cidr_block" {
  type        = string
  description = "Subnet cidr block"
  default     = "10.0.0.0/24"
}

variable "subnet_map_public_ip_on_launch" {
  type        = bool
  description = "Launched instances into subnet assign a public IP"
  default     = true
}
```

Actualizamos `main.tf`

```diff
# NETWORKING #
resource "aws_vpc" "vpc" {
- cidr_block           = "10.0.0.0/16"
+ cidr_block = var.vpc_cidr_block
- enable_dns_hostnames = "true"
+ enable_dns_hostnames = var.vpc_enable_dns_hostnames
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet1" {
- cidr_block              = "10.0.0.0/24"
+ cidr_block = var.subnet_cidr_block
  vpc_id     = aws_vpc.vpc.id
- map_public_ip_on_launch = "true"
+ map_public_ip_on_launch = var.subnet_map_public_ip_on_launch
}

# ROUTING #
```

### Paso 4. Actualizamos Routing

Creamos nuevas entradas en `variables.tf` para los recursos de routing.

```diff
variable "subnet_map_public_ip_on_launch" {
  type        = bool
  description = "Launched instances into subnet assign a public IP"
  default     = true
}
+
+# ROUTING
+variable "route_table_cidr_block" {
+ type        = string
+ description = "IP's to redirect to the internet by default all of them"
+ default     = "0.0.0.0/0"
+}
```

Actualizamos `main.tf`

```diff

# ROUTING #
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
-   cidr_block = "0.0.0.0/0"
+   cidr_block = var.route_table_cidr_block
    gateway_id = aws_internet_gateway.igw.id
  }
}
```

### Paso 5. Actualizamos Security Group

Creamos nuevas entradas en `variables.tf` par los recusos de los SG

```ini
# ....

# SECURITY GROUPS
variable "sg_ingress_cidr_blocks" {
  type        = list(string)
  description = "cidr blocks allow for ingress"
  default     = ["0.0.0.0/0"]
}

variable "sg_ingress_port" {
  type        = number
  description = "Ingress port to listen TCP"
  default     = 80
}

variable "sg_egress_cidr_blocks" {
  type        = list(string)
  description = "cidr blocks allow for egress"
  default     = ["0.0.0.0/0"]
}

variable "sg_egress_port" {
  type        = number
  description = "Egress port"
  default     = 0
}
```

Actualizamos `main.tf`

```diff
# ....
# SECURITY GROUPS #
resource "aws_security_group" "nginx-sg" {
  name   = "nginx_sg"
  vpc_id = aws_vpc.vpc.id

  # HTTP access from anywhere
  ingress {
-   from_port   = 80
+   from_port = var.sg_ingress_port
-   to_port     = 80
+   to_port  = var.sg_ingress_port
    protocol = "tcp"
-   cidr_blocks = ["0.0.0.0/0"]
+   cidr_blocks = var.sg_ingress_cidr_blocks
  }

  # outbound internet access
  egress {
-   from_port   = 0
+   from_port = var.sg_egress_port
-   to_port     = 0
+   to_port  = var.sg_egress_port
    protocol = "-1"
-   cidr_blocks = ["0.0.0.0/0"]
+   cidr_blocks = var.sg_egress_cidr_blocks
  }
}
# ....
```
mapas entradas en `variables.tf` para las instancias

```diff

variable "sg_egress_port" {
  type        = number
  description = "Egress port"
  default     = 0
}
+
+# INSTANCES
+variable "aws_instance_type" {
+ type        = string
+ description = "The EC2 instance to be used"
+ default     = "t2.micro"
+}
+
```

Actualizamos `main.tf`

```diff
# INSTANCES #
resource "aws_instance" "nginx1" {
  ami = nonsensitive(data.aws_ssm_parameter.ami.value)
- instance_type          = "t2.micro"
+ instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Lemon Land Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">Welcome to &#127819; land</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF

}

```

## Clean Up

```bash
terraform destroy
```