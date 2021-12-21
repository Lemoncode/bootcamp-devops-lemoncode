# Actualizando la VPC y las instancias

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d4.tfplan
terraform apply "d4.tfplan"
```

## Pasos

### Paso 1.

Creamos un nueva entrada en el fichero de variables, para controlar el número de instancias que queremos.

Actualizamos `variables.tf`

```diff
# NETWORKING
variable "vpc_cidr_block" {
  type        = string
  description = "VPC cidr block"
  default     = "10.0.0.0/16"
}
+
+variable "vpc_subnet_count" {
+ type        = number
+ description = "Number of subnets to create"
+ default     = 2
+}
+
variable "vpc_enable_dns_hostnames" {
  type        = bool
  description = "Enable / Disable DNS hostnames on VPC"
  default     = true
}
```

### Paso 2.

Ahora podemos actualizar el recurso de las subnets.

Actualizamos `network.tf`

```diff
+resource "aws_subnet" "subnets" {
+  count                   = var.vpc_subnet_count
+  cidr_block              = var.subnets_cidr_block[count.index]
+  vpc_id                  = aws_vpc.vpc.id
+  map_public_ip_on_launch = var.subnet_map_public_ip_on_launch
+ availability_zone       = data.aws_availability_zones.available.names[count.index]
+}
+
- resource "aws_subnet" "subnet1" {
-   cidr_block              = var.subnets_cidr_block[0]
-   vpc_id                  = aws_vpc.vpc.id
-   map_public_ip_on_launch = var.subnet_map_public_ip_on_launch
-   availability_zone       = data.aws_availability_zones.available.names[0]
-
-   tags = local.common_tags
- }
-
- resource "aws_subnet" "subnet2" {
-   cidr_block              = var.subnets_cidr_block[1]
-   vpc_id                  = aws_vpc.vpc.id
-   map_public_ip_on_launch = var.subnet_map_public_ip_on_launch
-   availability_zone       = data.aws_availability_zones.available.names[1]
-
-   tags = local.common_tags
- }
```

En consecuencia debemos actualizar la asociación de rutas paras las subnets.

```diff
-resource "aws_route_table_association" "rta-subnet1" {
+resource "aws_route_table_association" "rta-subnets" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rtb.id
}
```

```diff
resource "aws_route_table_association" "rta-subnets" {
+ count = var.vpc_subnet_count
- subnet_id      = aws_subnet.subnet1.id
+ subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.rtb.id
}
```

Ahora podemos eliminar `rta-subnet2`

```diff
-resource "aws_route_table_association" "rta-subnet2" {
-  subnet_id      = aws_subnet.subnet2.id
-  route_table_id = aws_route_table.rtb.id
-}
```

### Paso 3.

Ahora que hemos hecho esto vamos a actulizar las instancias.

Actualizamos `variables.tf`

```diff
# INSTANCES
variable "aws_instance_type" {
  type        = string
  description = "The EC2 instance to be used"
  default     = "t2.micro"
}
+
+variable "instance_count" {
+ type        = number
+ description = "Number of instances to create in VPC"
+ default     = 2
+}
+
```

Actualizamos `instances.tf`

```diff
# INSTANCES #
-resource "aws_instance" "nginx1" {
+resource "aws_instance" "nginx" {
+ count         = var.instance_count
  ami           = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type = var.aws_instance_type
- subnet_id              = aws_subnet.subnet1.id
+ subnet_id              = aws_subnet.subnets[count.index].id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on             = [aws_iam_role_policy.allow_s3_all]

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/index.html /home/ec2-user/index.html
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/fruits.png /home/ec2-user/fruits.png
sudo rm /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/fruits.png /usr/share/nginx/html/fruits.png
EOF

  tags = local.common_tags

}

-resource "aws_instance" "nginx2" {
-  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
-  instance_type          = var.aws_instance_type
-  subnet_id              = aws_subnet.subnet2.id
-  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
-  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
-  depends_on             = [aws_iam_role_policy.allow_s3_all]

-   user_data = <<EOF
- #! /bin/bash
- sudo amazon-linux-extras install -y nginx1
- sudo service nginx start
- aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/index.html /home/ec2-user/index.html
- aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/fruits.png /home/ec2-user/fruits.png
- sudo rm /usr/share/nginx/html/index.html
- sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
- sudo cp /home/ec2-user/fruits.png /usr/share/nginx/html/fruits.png
- EOF
-
-   tags = local.common_tags
-
- }
-
```

### Paso 4.

Por último actualizamos `loadbalancer.tf`

```diff
-resource "aws_lb_target_group_attachment" "nginx1" {
+resource "aws_lb_target_group_attachment" "nginx" {
+  count            = var.instance_count
  target_group_arn = aws_lb_target_group.nginx.arn
- target_id        = aws_instance.nginx1.id
+ target_id        = aws_instance.nginx[count.index].id
  port             = 80
}
-
-resource "aws_lb_target_group_attachment" "nginx2" {
-  target_group_arn = aws_lb_target_group.nginx.arn
-  target_id        = aws_instance.nginx2.id
-  port             = 80
-}
```

## Clean Up

```bash
terraform destroy
```