# Incorporando un nuevo proveedor a la Configuración

Queremos seguir introduciendo mejoras dentro de nuestra arquitectura, vamos a añdir un `S3 bucket` y alojar el contenido del website en el mismo. Después asignaremos un perfil a la instancia EC2 que tenga acceso para copiar el conetenido del bucket.

El `load balancer` soporta volcar sus `logs` a `S3`, así que aprovecharemos ese bucket para tal fin.

Los `S3 buckets` necesitan un nombre único a nivel mundial, y eso es lago que podemos generar con proveedor `random` para Terraform.

## Terraform Providers

* Public and private registries
* Official, Verified, and Community
* Open source
* Resources and data sources
* Versioned
* Multiple instances

## Especificando Required Providers

[Especificando Required Providers - Demo 12](12-demo.md)

## Incorporando el Proveedor Random 

[Incorporando el Proveedor Random](13-demo.md)

## Creando recursos IAM y S3

Vamos a crear un bucket S3 y hospedar objetos en este para el website. Para tal fin vamos a usar `aws_s3_bucket` resource y `aws_s3_bucket_object` resource. 


```tf
# S3 Resources

"aws_s3_bucket" # S3 bucket itself

"aws_s3_bucket_object" # Objects in the bucket
```

Nuestras instancias EC2 necesitaran acceso al bucket de S3, pero no queremos que sea público para todo el mundo, lo que vamos a hacer es crear recursos IAM para dar acceso a las instancias EC2.

```tf
# S3 Resources

"aws_s3_bucket" # S3 bucket itself

"aws_s3_bucket_object" # Objects in the bucket

# IAM Resources

"aws_iam_role" # Role for instances

"aws_iam_role_policy" # Role policy for S3 access

"aws_iam_instance_profile" # Instance profile
```


Crearemos un role usando `aws_iam_role` y darle permisos al bucket con `aws_iam_role_policy`. Después podemos asignar el role a la instancia EC2 creando un recurso `aws_iam_instance_profile` y después añadir un entrada `aws_instance` block para usar este  `instance profile`. 

```tf
# S3 Resources

"aws_s3_bucket" # S3 bucket itself

"aws_s3_bucket_object" # Objects in the bucket

# IAM Resources

"aws_iam_role" # Role for instances

"aws_iam_role_policy" # Role policy for S3 access

"aws_iam_instance_profile" # Instance profile

# Data Source

"aws_elb_service_account" # For load balancer access
```

Necesitamos dar acceso al balanceador de carga al bucket S3, y lo podemos hacer a través de una policy que refiera la fuente de datos `aws_elb_service_account`. Esto nos dará la cuenta principal del servicio para el `elastic load balancer` en la región en la que estemos trabajando, y podremos darle acceso a este bucket.

[Esqueleto recursos IAM y S3 - Demo 14](14-demo.md)

## Analizando la configuración actualizada

[Cerrando recursos S3 - Demo 15](15-demo.md)

## Dependencias y Planning

Cuando Terraform intenta hacer un despliegue, tiene que atravesar un proceso de planning. Este proceso se ejecuta cuando realizamos las siguientes acciones: `plan`, `apply` y `destroy`. Como parte del proceso de planning, **necesita descubrir en que orden crear, actualizar o borrar los objetos**

### Terraform Planning 

* Refrescar e inspeccionar el estado
* Grafo de dependencias
* Incorporaciones, actualizaciones y borrados
* Ejecución en paralelo

### Determinando las Dependencia

> Visitar diagrama

## Actualizando el Balancedor de carga y las instancias

[Actualizando el Balancedor de carga y las instancias - Demo 16](16-demo.md)

## Configuración Post Deployment

Después de que un recurso ha sido creado, a veces necesitamos realizar configuraciones `pos-deployment`

### Opciones de Configuración

* Resource 
* Pass data
* Config Manager
* Provisioner

### Provisioners

* Definidos en el recurso
* Creación o destrucción
* Múltiples provisioners
* null_resource
* Failure options
* Último recurso 

## Actualizando el Startup Script

[Actualizando el Startup Script - Demo 17](17-demo.md)

## Desplegando la nueva configuración

[Desplegando la nueva configuración - Demo 18](18-demo.md)