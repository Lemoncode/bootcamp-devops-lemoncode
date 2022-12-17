# Actualizando el Startup Script

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d3.tfplan
terraform apply "d3.tfplan"
```

Nuestro objetivo es actulaizar el script de `user_data`. Lo que queremos ahora, es recuperar los ficheros que están en S3 y definen nuestro site.

Las buenas noticias es que la AWS CLI ya viene instalada an la AMI que hemos seleccionado.

Actualizamos `instances.tf`

```diff
# INSTANCES #
resource "aws_instance" "nginx1" {
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on = [
-   aws_iam_role_policy.allow_s3_all
+   aws_iam_role_policy.allow_s3_all,
+   aws_s3_object.website,
+   aws_s3_object.graphic
  ]

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
+aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/index.html /home/ec2-user/index.html
+aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/fruits.png /home/ec2-user/fruits.png
sudo rm /usr/share/nginx/html/index.html
+sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
+sudo cp /home/ec2-user/fruits.png /usr/share/nginx/html/fruits.png
-echo '<html><head><title>Lemon Land Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">Welcome to &#127819; land</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF

  tags = local.common_tags

}

resource "aws_instance" "nginx2" {
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on = [
-   aws_iam_role_policy.allow_s3_all
+   aws_iam_role_policy.allow_s3_all,
+   aws_s3_object.website,
+   aws_s3_object.graphic
  ]

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
+aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/index.html /home/ec2-user/index.html
+aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/website/fruits.png /home/ec2-user/fruits.png
sudo rm /usr/share/nginx/html/index.html
+sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
+sudo cp /home/ec2-user/fruits.png /usr/share/nginx/html/fruits.png
-echo '<html><head><title>Lemon Land Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">Welcome to &#127819; land</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF

  tags = local.common_tags

}

```


## Clean Up

```bash
terraform destroy
```