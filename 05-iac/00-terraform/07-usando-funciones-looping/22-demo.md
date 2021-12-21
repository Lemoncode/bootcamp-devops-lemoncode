# Usando la función templatefile

## Pre requisitos

> Si has destruido el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d4.tfplan
terraform apply "d4.tfplan"
```

## Pasos

### Paso 1. Creamos un fichero template

Creamos el fichero `lab/lc_web_app/start_script.tpl`

> La extensión del fichero no es requerida por Terraform

```bash
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/index.html /home/ec2-user/index.html
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/fruits.png /home/ec2-user/fruits.png
sudo rm /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/fruits.png /usr/share/nginx/html/fruits.png
```

### Paso 2. Alimentando valores

Notar que estamos referenciando el atributo `aws_s3_bucket.web_bucket.id`. Cuando el fichero de template sea evaluado, no va a ser capaz de evaluar esa expresión directamente.

Necesitamos pasar una variable que podamos alimentar desde la función que modifica el template.

```diff
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
-aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/index.html /home/ec2-user/index.html
+aws s3 cp s3://${s3_bucket_name}/website/index.html /home/ec2-user/index.html
-aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/fruits.png /home/ec2-user/fruits.png
+aws s3 cp s3://${s3_bucket_name}/website/fruits.png /home/ec2-user/fruits.png
sudo rm /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/fruits.png /usr/share/nginx/html/fruits.png
```

### Paso 3. Actualizando las instancias

Actualizar `instances.tf`

```diff
resource "aws_instance" "nginx" {
  count         = var.instance_count
  ami           = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type = var.aws_instance_type
  # subnet_id              = aws_subnet.subnet1.id
  subnet_id              = aws_subnet.subnets[count.index].id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on             = [aws_iam_role_policy.allow_s3_all]

-   user_data = <<EOF
- ! /bin/bash
- sudo amazon-linux-extras install -y nginx1
- sudo service nginx start
- aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/index.html /home/ec2-user/index.html
- aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/fruits.png /home/ec2-user/fruits.png
- sudo rm /usr/share/nginx/html/index.html
- sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
- sudo cp /home/ec2-user/fruits.png /usr/share/nginx/html/fruits.png
- EOF
+
+ user_data = templatefile("${path.module}/startup_script.tpl")
+
  tags = local.common_tags

}
```

Para encontrar el `path` al fichero de template, usamos la variable `path.module`, esta variable nos devuelve el full path del módulo en el que estamos trabajando.

Para alimentar el valor de `s3_bucket_name` pasamos un map como segundo argumento.

```diff
# INSTANCES #
resource "aws_instance" "nginx" {
  count                  = var.instance_count
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.subnets[count.index].id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on = [
    aws_iam_role_policy.allow_s3_all
  ]

- user_data = templatefile("${path.module}/startup_script.tpl")
+ user_data = templatefile("${path.module}/startup_script.tpl", {
+   s3_bucket_name = aws_s3_bucket.web_bucket.id
+ })
+
  tags = local.common_tags

}

```

## Clean Up

```bash
terraform destroy
```