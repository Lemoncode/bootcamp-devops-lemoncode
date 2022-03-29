# Incorporando los Recursos del Balanceador de Carga

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d2.tfplan
terraform apply "d2.tfplan"
```

## Pasos

### Paso 1. Buscar en la documentación

Si buscamos en la documentación `elastic load balancing v2`, encontraremos `aws_lb` bajo `Resources` y `Data`.

> Lo tenemos debajo Data, porque podemos utilizar uno que ya existiera.

> EXERCISE: A partir de la documentación actualizar  `loadbalancer.tf`

```ini
## aws_lb
resource "aws_lb" "nginx" {
  name               = "lc_web_alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  enable_deletion_protection = false

  tags = local.common_tags
}

```

### Paso 2. Añadimos el target group

Incorporamos el recurso `aws_lb_target_group`

```diff

## aws_lb_target_group
+resource "aws_lb_target_group" "nginx" {
+ name     = "lc_web_alb_tg"
+ port     = 80
+ protocol = "HTTP"
+ vpc_id   = aws_vpc.vpc.id
+
+ tags = local.common_tags
+}
```

### Paso 3. Añadimos el listener

Incorporamos el recurso `aws_lb_listener`

```diff
## aws_lb_listener
+resource "aws_lb_listener" "nginx" {
+ load_balancer_arn = aws_lb.nginx.arn
+ port              = "80"
+ protocol          = "HTTP"
+ 
+ default_action {
+   type             = "forward"
+   target_group_arn = aws_lb_target_group.nginx.arn
+ }
+
+ tags = local.common_tags
+}
```

### Paso 4. Enlazamos las instancias

Incorporamos el recurso `aws_lb_target_group_attachment`

```diff
## aws_lb_target_group_attachment
+resource "aws_lb_target_group_attachment" "nginx1" {
+  target_group_arn = aws_lb_target_group.nginx.arn
+  target_id        = aws_instance.nginx1.id
+  port             = 80
+}
+
+resource "aws_lb_target_group_attachment" "nginx2" {
+  target_group_arn = aws_lb_target_group.nginx.arn
+  target_id        = aws_instance.nginx2.id
+  port             = 80
+}
```


## Clean Up

```bash
terraform destroy
```