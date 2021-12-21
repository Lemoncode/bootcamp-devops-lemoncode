# Desplegando la nueva configuración

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d3.tfplan
terraform apply "d3.tfplan"
```

## Pasos

### Paso 1.

Nos aseguramos de que nuestros ficheros están debidamente formateados.

```bash
terraform fmt
```

### Paso 2.

Ahora tenemos que ejecutar `terraform init`, cada vez que tenemos un nuevo provider, debemos ejecutar este comando para que Terraform pueda descargar los binarios.

```bash
terraform init
```

We get something similar to this:

```bash
Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Finding hashicorp/random versions matching "~> 3.0"...
- Installing hashicorp/random v3.1.0...
- Installed hashicorp/random v3.1.0 (signed by HashiCorp)
- Using previously-installed hashicorp/aws v3.70.0

Terraform has made some changes to the provider dependency selections recorded
in the .terraform.lock.hcl file. Review those changes and commit them to your
version control system if they represent changes you intended to make.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Paso 3.

Validamos nuestra configuración

```bash
terraform validate
```

Si todo va bien deberíamos ver:

```bash
Success! The configuration is valid.
```

### Paso 4.

Recordar que debemos alimentar las variables de entorno: 

```bash
AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=YOUR_SECRET_ACCESS_KEY
```

### Paso 5.

Ahora podemos ejecutar la planificación

```bash
terraform plan -out d4.tfplan
```

Obtenemos algo similar a esto:

```bash
Plan: 7 to add, 3 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: d4.tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "d4.tfplan"

```

### Paso 6.

Ahora podemos aplicar el plan.

```bash
terraform apply "d4.tfplan"
```

Pasados unos minutos veremos:

```bash
aws_s3_bucket.web_bucket: Creating...
aws_s3_bucket.web_bucket: Creation complete after 5s [id=lc-web-app-20359]
aws_s3_bucket_object.graphic: Creating...
aws_s3_bucket_object.website: Creating...
aws_lb.nginx: Modifying... [id=arn:aws:elasticloadbalancing:eu-west-3:092312727912:loadbalancer/app/lc-web-alb/8f8f5d121be16dfe]
aws_s3_bucket_object.website: Creation complete after 1s [id=/website/index.html]
aws_s3_bucket_object.graphic: Creation complete after 1s [id=/website/fruits.png]
aws_lb.nginx: Still modifying... [id=arn:aws:elasticloadbalancing:eu-west-3:...lancer/app/lc-web-alb/8f8f5d121be16dfe, 10s elapsed]
aws_lb.nginx: Still modifying... [id=arn:aws:elasticloadbalancing:eu-west-3:...lancer/app/lc-web-alb/8f8f5d121be16dfe, 20s elapsed]
aws_lb.nginx: Still modifying... [id=arn:aws:elasticloadbalancing:eu-west-3:...lancer/app/lc-web-alb/8f8f5d121be16dfe, 30s elapsed]
aws_lb.nginx: Modifications complete after 31s [id=arn:aws:elasticloadbalancing:eu-west-3:092312727912:loadbalancer/app/lc-web-alb/8f8f5d121be16dfe]

Apply complete! Resources: 3 added, 1 changed, 0 destroyed.

Outputs:

aws_instance_public_dns = "lc-web-alb-73418185.eu-west-3.elb.amazonaws.com"
```

Visitemos la página del load balancer `lc-web-alb-XXXXXX.eu-west-3.elb.amazonaws.com` y refrescar múltiples veces.

Nos podemos registrar en la consola de AWS y buscar el bucket `lc-web-alb-XXXXXX`, deberíamos ser capaces de ver `alb-logs`, `AWSLogs`, `XXXXXXXXXXXX` y aquí ver nuestros logs.

### Trouble shooting

https://github.com/hashicorp/terraform-provider-aws/issues/9896

## Clean Up

```bash
terraform destroy
```