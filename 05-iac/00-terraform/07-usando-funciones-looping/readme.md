# Usando Funciones y Looping

Vamos a seguir mejorando nuestra arquitectura a través de las características que nos ofrece Terraform. Lo que queremos conseguir ahora, son las siguientes características:

* Incrementar las instancias de for dinámica
* Usar una plantilla para `startup script`
* Simplificar las entradas en el networking
* Añadir prefijos de nombres consistentes

## Loops

* Count - Integer
* for_each - Map or set
* Dynamic blocks - Map or set

## ¿Dónde usarlo en nuestra solución?

```
# Primary resources

"aws_subnets" # Count loop

"aws_instance" # Count loop

"aws_s3_bucket_object" # for_each loop

# Impacted resources

"aws_route_table_association"

"aws_lb_target_group_attachement"
```

## Actualizando la VPC y las instancias

[Actualizando la VPC y las instancias - Demo 19](19-demo.md)

## Actualizando S3 Bucket Objects

[Actualizando S3 Bucket Objects - Demo 20](20-demo.md)

## Terraform Expresiones y Funciones

Terraform incluye funciones y expresiones para manipular los datos dentro de los ficheros HCL.

### Terraform Expresiones

* Interpolación y heredoc
* Operadores aritméticos y lógicos
* Expresiones condicionales
* Expresiones for

### Terraform Funciones

* Built-in Terraform
* func_name(arg1, arg2Usando la función templatefile
  * lower("CAMPERO")
* Collection
  * merge(map1, map2)
* IP network
  * cidrsubnet()
* Filesystem
  * file(path)
* Type Conversion
  * toset()

## ¿Dónde usar las funciones?

```tf
# Startup script 
templatefile(file_location, {map of variables})

# Extract subnet address from VPC CIDR
cidrsubnet(cidr_range, subnet bits to add, network number)

# Add tags to common tags
merge(common_tags, { map of additional tags })

# S3 bucket name
lower("bucket name")
```

## Testeando las Funciones con la Consola de Terraform

[Testeando las Funciones con la Consola de Terraform - Demo 21](21-demo.md)

## Usando la función templatefile

[Usando la función `templatefile` - Demo 22](22-demo.md)

## Usando la función cidrsubnet

[Usando la función cidrsubnet - Demo 23](23-demo.md)

## Añadiendo prefijos al nobrado

[Añadiendo prefijos al nobrado - Demo 24](24-demo.md)

## Desplegando la Configuración Actualizada

[Desplegando la Configuración Actualizada - Demo 25](25-demo.md)
