# Desplegando la Configuración Base

## ¿Qué es Terraform?

* Infrastructure automation tool
* Open-source y vendor agnostic
* Un binario compilado - Go
* Sintaxis declarativa
* Hashicorp Configuration Language o JSON
* Push based Deployment

## Core Components

* Executable
* Configuration Files
* Provider plugins
* State data

## Tipos de Objetos en Terraform

* Providers
* Resources
* Data sources

## Sintaxis Común de Bloque

```tf
resource "aws_instance" "web_server" {
  name = "web-server"
  ebs_volume {
    size = 40c:\path;c:\path2
```

### Referenciando Objetos

```
aws_instance.web_server.name
```

## Revisando la configuración base

Abrimos `./.start-app/main.tf`

```tf
provider "aws" {
  access_key = "ACCESS_KEY"
  secret_key = "SECRET_KEY"
  region     = "us-east-1"
}
```

Este bloque le indica a Terraform que usaremos `AWS` como **provider**.

```tf
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
```

[Blog reference](https://aws.amazon.com/blogs/compute/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/)

Este es un **service manager parameter**, al cual le damos como nombre de etiqueta `ami`.  Dentro de este bloque, estamos alimentando el `path` a un parámetro en particular. En este caso, el parametro devuelve la última Amazon Linux 2 AMI ID.

En la sección de `NETWORKING` creamos la `VPC`

```tf
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = "true"

}
```

Después creamos la `internet gateway`, y lo asociamos con la VPC que creamos previamente. Para tal fin usamos `vpc_id = aws_vpc.vpc.id`

```tf
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

}
```

> ¿Cómo sabemos que argumentos y atributos están disponibles para un recurso? Tenemos que leer la documentación `;)`: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

Creamos una `subnet` asociada a la `VPC`. Gracias a esta entrada `map_public_ip_on_launch = "true"`, obtenemos una IP pública

```tf
resource "aws_subnet" "subnet1" {
  cidr_block              = "10.0.0.0/24"
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "true"
}
```

Creamos una `route table`, y la asociamos a nuestra `VPC`. Para ver la documentación oficial de este recurso, seguir el siguiente enlace [Route tables official Docs](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html) 

```tf
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
```

En el bloque anidado, podemos especificar un `route` para añadir a la `route table`. En este caso estamos creando una `default route` y la apuntamos a la `internet gateway`. De esta manera el tráfico puede salir fuera de la `VPC` a través de la `internet gateway`.

Por último asociamos nuestra `route table` con una única `subnet`

```tf
resource "aws_route_table_association" "rta-subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rtb.id
}
```

Creamos un `security group` que permita al puerto 80 de cualquier dirección hablar nuestra instancia `EC2`

```tf
# Nginx security group 
resource "aws_security_group" "nginx-sg" {
  name   = "nginx_sg"
  vpc_id = aws_vpc.vpc.id

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

Estamos asocaindo este `security group` con nuestra `VPC`, y estamos creando un único `ingress group` usando un bloque anidado, y dentro de este, establecemos la entrada `from_port` y `to_port` al puerto 80, el protocolo TCP y el `cidr_block` que refiere a todas las direcciones.

Por último tenemos la instancia EC2.

```tf
resource "aws_instance" "nginx1" {
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = "t2.micro"
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

> NOTA: Explicar el Workflow de Terraform

Ahora estamos listos para aplicar el contenido de `main.tf` 

[Desplegando la configuración base - Demo 01](01-demo)

## Terraform Workflow

> Mostrar diagrama