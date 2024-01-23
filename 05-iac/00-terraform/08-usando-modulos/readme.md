## Introducción

Una característica común de los lenguajes de programación es la capacidad de importar bibliotecas o módulos para tareas, estructuras de datos o funciones comunes. Terraform implementa una capacidad similar mediante el uso de módulos.

Los módulos de Terraform impiden reinventar la rueda al permitir usar configuraciones comunes creadas por otros.

## Terraform Modules

Ya sea que se dé cuenta o no de que ha estado usando módulos Terraform todo el tiempo, ¿qué es un módulo Terraform?

* Inputs 
* Resources
* Outputs

Es simplemente una configuración que define `inputs`, `resources` y `outputs`, y todas ellas son opcionales.

Cuando creamos un conjuno de ficheros `tf` o `tf.json` en un directorio, eso es un módulo.

```
module/
├─ HCL
├─ JSON
```


La configuración principal con la que estmaos trabajando se conoce como módulo raíz (`root`) y puede invocar otros módulos para crear recursos. Los módulos pueden formar una jerarquía con el módulo raíz (`root`) en la parte superior.

```
root/
├─ HCL
├─ JSON
├─ module/
```

Nuestro módulo raíz (`root`) podría invocar un módulo hijo, que a su vez podría invocar otro módulo hijo.

```
root/
├─ HCL
├─ JSON
├─ module/
    ├─ HCL
    ├─ JSON
    ├─ other_module/
```


Por ejemplo, digamos que usamos un módulo para crear un balanceador de carga con una VPC y una instancia EC2. El módulo balanceador de carga puede utilizar un módulo para crear la VPC y otro para crear cada instancia EC2.

### Terraform Modules

* Code reuse
* Remote or local source
* Versioning
* `terraform init`
* Multiple instances

La motivación detrás de la creación o el uso de módulos es aprovechar un conjunto común de recursos y configuraciones para su implementación.

¿Dónde puedes conseguir módulos? Pueden obtenerse del sistema de archivos local, de un registro remoto o de cualquier sitio web implementado correctamente que siga el protocolo del proveedor de HashiCorp. La fuente más común es el registro público Terraform. De hecho, es posible que hayas notado la opción del módulo de exploración en el registro público.

Los módulos alojados en un registro también tienen versiones de la misma manera que los proveedores. Puede especificar una versión para usar al invocar un módulo. Mantener su versión preferida puede evitar que los cambios importantes afecten sus implementaciones.

Una vez que haya agregado el módulo a su configuración, `terraform init` descargará el módulo desde la ubicación de origen a su directorio de trabajo. Si el módulo ya está en el directorio de trabajo actual, Terraform no hará una copia del mismo. 

Puedes crear múltiples instancias de un módulo usando los metaargumentos count o for_each.

### Module Components

Los componentes que componen un módulo ya deberían resultarle muy familiares.

* Input Variables
* Output values
* Resources / Data Resources

Los módulos generalmente tienen variables de entrada, por lo que puede proporcionar valores de entrada al módulo y valores de salida que se basan en lo que el módulo está creando y, por supuesto, los recursos y fuentes de datos reales dentro del módulo. 

No es necesario que un módulo tenga ninguno de estos componentes, pero probablemente no sería muy útil sin ellos. 

## Actualizacione

* Aprovechar el módulo VPC para la creación de redes
* Crear un módulo para S3 bucket
  * Incluir permisos para el load balancer
  * Incluir permisos para instance profile

## Adding the VPC Module

[Demo Adding the VPC Module](./26-demo.md)

## For Expressions

For expressions son una forma de crear una nueva colección basada en otro objeto de colección. Es especialmente útil cuando se trata de recursos que tienen un recuento o un valor para cada argumento.

* Input types - List, set, tuple, map or object
* Result types - Tuple or object
* Filtering with if statement

La entrada en una expresión for puede ser cualquier tipo de datos de colección, lista, conjunto, tupla, mapa o incluso objeto. El contenido de la colección estará disponible para su transformación en la expresión for.

El resultado de la expresión for será una tupla o un tipo de datos de objeto. Recuerde que estos son tipos de datos estructurales, lo que significa que no todos los valores internos tienen que ser del mismo tipo de datos.

Para ayudar a personalizar el resultado, puede filtrarlo con una declaración if. Puede filtrar por cualquier valor de las entradas. 

Revisemos la sintaxis de una expresión for para dar algo de claridad.

```ini
# Create a tuple
[ for item in items : tuple_element ]
```

Primero, veamos cómo crearías un resultado de tupla con una expresión for. La expresión comienza con llaves o corchetes. **Los corchetes indican que el resultado será una tupla**.

> Los corchetes o llaves que utiliza para encapsular la expresión for determinan el tipo de resultado.

Después de los corchetes, la expresión comienza con la palabra clave `for`, seguida de la sintaxis que identifica el valor de entrada y el término iterador que se utilizará durante la evaluación. La estructura es el término iterador, seguido de `in` y luego el valor de entrada. Después de eso tenemos dos puntos, que señalan el inicio del valor que se almacenará en cada elemento de tupla en la colección resultante.

Si esto suena esotérico y difícil de analizar, estoy de acuerdo y creo que un ejemplo aclarará las cosas.

```ini
# Example
locals {
  toppings = ["cheese", "lettuce", "salsa"]
}

[ for t in local.toppings : "Campero ${t}" ]

# Result
["Campero cheese", "Campero lettuce", "Campero salsa"]
```

Digamos que tenemos un valor local llamado toppings de tipo lista con tres elementos y nos gustaría crear una nueva tupla con la palabra Campero agregada a cada elemento de la lista. Podemos lograr esto con una expresión for. El corchete dice que queremos una tupla como resultado. La t es el marcador de posición para cada valor en el valor de entrada local.toppings. Después de los dos puntos está el valor resultante que queremos usar para cada elemento, que es simplemente la cadena Campero y el valor almacenado en el marcador de posición t. La tupla resultante tendrá tres elementos, **queso campero**, **lechuga campero** y **salsa campero**. Recuerde que el valor de entrada no tiene por qué coincidir con el resultado. Los ingredientes locales podrían haber sido un mapa. Ahora veamos la sintaxis para crear un objeto. 

La expresión comenzará con llaves para indicar que queremos un objeto como resultado.

```ini
{ for key, value in map : obj_key => obj_value }
```

Como repaso rápido, un objeto es básicamente un conjunto de pares clave-valor donde los valores pueden ser de diferentes tipos de datos. En esta expresión, el valor de entrada es un mapa, lo que significa que ahora necesitamos dos identificadores de iterador, uno para la clave y otro para el valor. A continuación, tenemos dos puntos y una expresión para evaluar para cada entrada en el objeto. La sintaxis es la clave del objeto, seguida de igual y el símbolo mayor que y luego el valor del objeto.


Ejemplo:


```ini
# Example
locals {
  prices = {
    campero = "5.99"
    perrito = "9.99"
    papa = "7.99"
  }
}

{ for i, p in local.prices : i => ceil(p) }

# Result
{ campero = "6", perrito = "10", papa = "8" }
```

Aquí hay un valor local llamado precios de tipo mapa con tres pares de valores clave. Digamos que queremos un nuevo objeto donde cada precio se redondee al siguiente entero entero. Podemos hacer eso con una expresión for, donde i es la clave del mapa y p es el valor del mapa. La expresión a evaluar mantiene la misma clave i, pero altera el valor con la función techo. El objeto resultante tiene el valor de cada par redondeado al número entero más cercano. 

## Using a For Expression

[Demo Using a For Expression](./27-demo.md)

## Creating the S3 Module

```ini
# Input variables - variables.tf
"bucket_name" # Name of bucket

"elb_service_account_arn" # ARN of ELB service account

"common_tags" # Tags to apply to resources

# Resources - main.tf
"aws_s3_bucket"

"aws_iam_role"

"aws_iam_role_policy"

"aws_iam_instance_profile"

# Outputs - outputs.tf
"web_bucket" # Full bucket object

"instance_profile" # Full instance profile object
```

El módulo S3 que estamos creando debe crear un bucket S3 con una política de bucket que permita a un balanceador de carga escribir registros y los recursos de IAM adecuados para otorgar acceso a una instancia EC2.

Nuestras entradas incluirán el nombre del bucket, `elb_service_account_arn` y las `common_tags` que se aplicarán a todos los recursos. Todos ellos pueden ir en el archivo `variables.tf`.

Los recursos que necesitamos crear ya existen en nuestra configuración. Tenemos el bucket de S3 en sí, la función de IAM, la policy function y el instance profile.

En términos de valores de salida, usaremos el bucket S3 y el instance profile. Simplemente podemos devolver el objeto completo para cada recurso y hacer uso de todos los atributos que contiene.  

[Demo Creating the S3 Module](./28-demo.md)

## Adding the S3 Module

[Demo Adding the S3 Module](./29-demo.md)

## Validating and Applying the Updated Configuration

[Demo Validating and Applying the Updated Configuration](./30-demo.md)