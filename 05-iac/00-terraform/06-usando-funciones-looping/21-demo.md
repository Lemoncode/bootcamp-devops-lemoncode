# Testeando las Funciones con la Consola de Terraform

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d4.tfplan
terraform apply "d4.tfplan"
```

## Pasos

### Paso 1. Console setup

Necesitamos inicializar la configuración para que la consola de Terraform funcione. En nuestro caso ya esta inicializada así que no deberíamos tener que preocuparnos por esto.

```bash
terraform init
```

```bash
Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/random from the dependency lock file
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/random v3.1.0
- Using previously-installed hashicorp/aws v3.70.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Paso 2. Arrancar la consola.

```bash
terraform console
```

Ahora podemos probar diferentes funciones

```bash
min(89, 90, 4)
lower("TOMATO")
```

Vamos a testear `cidrsubnet` alimentando el valor `vpc_cidr_block`. Podemos comprobar su valor por defecto de la siguiente forma:

[cidrsunet docs](https://www.terraform.io/language/functions/cidrsubnet)

``` 
> var.vpc_cidr_block
"10.0.0.0/16
```

Y la podemos usar de la siguiente manera

```
> cidrsubnet(var.vpc_cidr_block, 8, 0)
"10.0.0.0/24"
> cidrsubnet(var.vpc_cidr_block, 8, 4)
"10.0.4.0/24"
```

Otra funcion interesante es `lookup`, que nos ayuda a encontrar un valor en un `map`

```
> lookup(local.common_tags, "company", "Unknown")
"Lemoncode"
> lookup(local.common_tags, "missing", "Unknown")
"Unknown"
```

Por supuesto, podemos seguir simplemente pidiendo un valor como hemos hecho previamente:

```
> local.common_tags
{
  "billing_code" = "FOO9999"
  "company" = "Lemoncode"
  "project" = "Lemoncode-web-app"
}
```

## Clean Up

```bash
terraform destroy
```