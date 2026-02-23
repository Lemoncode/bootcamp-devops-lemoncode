# Actualizando nuestra configuración con más recursos

Vamos a mejorar la arquitectura de la solución actualmente tenemos una sola instancia de la misma. En este escenario, no podemos asegurar, una alta disponibilidad de la aplicación.

* Añadir una segunda zona de disponibilidad
* Añadir una nueva instancia EC2
* Añadir un balanceador de carga
* Mantener la legibilidad deel código.

Para añadir todos estos requisitos vamos a incuir las siguientes entradas:

```
# Data source
"aws_availability_zones" # List of current availability zones

# Load balancer resources
"aws_lb" # AWS Application Load Balancer
"aws_lb_target_group" # Target group for load balancer
"aws_lb_listener" # Listener configuration for target group
"aws_lb_target_group_attachement" # Attach for EC2 instances
```

## Añadiendo nuevos recuros a la configuración

[Añadiendo nuevos recursos a la configuración - Demo 07](07-demo.md)

## Usando la Documentación

En la demo anterior hemos hemos dejado abierto una serie de recursos, los cuales necesitamos para añadir el balanceo de carga, la pregunta es dónde podemos encontrar como generar estos recursos, la respuesta es usando la documentación: [registry.terraform.io](https://registry.terraform.io/)

[Añadiendo availability zones - Demo 08](08-demo.md)

## Actualizando Network y la Configuración de Instancia

[Actualizando Network y la Configuración de Instancia - Demo 09](09-demo.md)

## Incorporando los Recursos del Balanceador de Carga

[Incorporando los Recursos del Balanceador de Carga - Demo 10](10-demo.md)

## Viewing State Data

### Terraform State

* JSON format (Do not touch!)
* Resources mappings and metadata
* Locking
* Location
  * Local
  * Remote: AWS, Azure, NFS, Terraform Cloud
* Workspaces

### State Commands

```bash
# List all state 
terraform state list

# Show a specific resource
terraform state show ADDRESS

# Move an item in state
terraform state mv SOURCE DESTINATION

# Remove an item in state
terraform state rm ADDRESS
```

> Primera regla de Terraform? --> Haz todos los cambios con Terraform.

## Desplegando la Arquitectura Actualizada

[Desplegando la Arquitectura Actualizada - Demo 11](11-demo.md)