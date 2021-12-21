# Actualizando el Balancedor de carga y las instancias

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d3.tfplan
terraform apply "d3.tfplan"
```

## Pasos

### Paso 1. Actualizamos el Balanceador de Carga

Actualizamos `loadbalancer.tf`

```diff

## aws_lb
resource "aws_lb" "nginx" {
  name               = "lc-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  enable_deletion_protection = false
+
+ access_logs {
+   bucket  = aws_s3_bucket.web_bucket.bucket
+   prefix  = "alb-logs"
+   enabled = true
+ }
+
  tags = local.common_tags
}
```

### Paso 2. Actualizamos las instancias

```diff
# INSTANCES #
resource "aws_instance" "nginx1" {
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
+ iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
+ depends_on = [
+   aws_iam_role_policy.allow_s3_all
+ ]
+  
  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Lemon Land Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">Welcome to &#127819; land</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF

  tags = local.common_tags

}

resource "aws_instance" "nginx2" {
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
+ iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
+ depends_on = [
+   aws_iam_role_policy.allow_s3_all
+ ]
+
  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Lemon Land Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">Welcome to &#127819; land</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF

  tags = local.common_tags

}

```

## Clean Up

```bash
terraform destroy
```