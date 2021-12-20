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


## Clean Up

```bash
terraform destroy
```