# Usando Validate

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d1.tfplan
terraform apply "d1.tfplan"
```

```bash
terraform validate
```

## Clean Up

```bash
terraform destroy
```