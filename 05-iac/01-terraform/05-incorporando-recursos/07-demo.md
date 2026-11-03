# Añadiendo nuevos recursos a la configuración

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d2.tfplan
terraform apply "d2.tfplan"
```

## Pasos

### Paso 1. Crear nuevos recursos y renombrar

* Crear `./lab/lc_web_app/loadbalancer.tf`
* Crear `./lab/lc_web_app/instances.tf`
* Renombrar `./lab/lc_web_app/main.tf` --> `./lab/lc_web_app/network.tf`

### Paso 2. Movemos la instancia a su propio fichero.

Cortamos el contenido en `network.tf` 

```diff
- # INSTANCES #
- resource "aws_instance" "nginx1" {
-   ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
-   instance_type          = var.aws_instance_type
-   subnet_id              = aws_subnet.subnet1.id
-   vpc_security_group_ids = [aws_security_group.nginx-sg.id]
-
-   user_data                   = <<-EOF
-             #!/bin/bash
-             # Update package lists
-             yum update -y
-             # Install NGINX from Amazon Linux Extras
-             amazon-linux-extras install -y nginx1
-
-             # Create custom landing page before starting the service
-             cat <<'HTML' > /usr/share/nginx/html/index.html
-             <!DOCTYPE html>
-             <html>
-             <head><title>Lemon Land Server</title></head>
-             <body style="background-color:#1F778D;">
-               <p style="text-align: center;">
-                 <span style="color:#FFFFFF; font-size:28px;">You did it! Have a &#127790;</span>
-               </p>
-             </body>
-             </html>
-             HTML
-
-             # Enable and start NGINX
-             systemctl enable --now nginx
-             EOF
-
-   tags = local.common_tags
-
- }
```

Y lo añadimos a `instances.tf`

```ini
# INSTANCES #
resource "aws_instance" "nginx1" {
  ami                         = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type               = var.aws_instance_type
  subnet_id                   = aws_subnet.subnet1.id
  vpc_security_group_ids      = [aws_security_group.nginx-sg.id]
  
  user_data                   = <<-EOF
              #!/bin/bash
              # Update package lists
              yum update -y

              # Install NGINX from Amazon Linux Extras
              amazon-linux-extras install -y nginx1

              # Create custom landing page before starting the service
              cat <<'HTML' > /usr/share/nginx/html/index.html
              <!DOCTYPE html>
              <html>
              <head><title>Lemon Land Server</title></head>
              <body style="background-color:#1F778D;">
                <p style="text-align: center;">
                  <span style="color:#FFFFFF; font-size:28px;">You did it! Have a &#127790;</span>
                </p>
              </body>
              </html>
              HTML

              # Enable and start NGINX
              systemctl enable --now nginx
              EOF
  
  tags = local.common_tags
}

```

### Paso 3. Nos preparamos para añadir los recursos del balanceo de carga 

Actualizamos `loadbalancer.tf`

```ini
## aws_lb

## aws_lb_target_group

## aws_lb_listener

## aws_lb_target_group_attachment
```

## Clean Up

```bash
terraform destroy
```