# Gestión del estado

## Introducción

El pegamento que mantiene unido a Terraform es el estado. Los datos de estado asignan lo que hay dentro de su configuración a los recursos del mundo real que se encuentran en el proveedor de la nube pública o en cualquier lugar donde esté implementando su infraestructura. El estado es fundamental y necesitará saber cómo gestionarlo de forma eficaz.

## Casuistica

Creamos infrastructura para ser consumida por otros equipos / desarrolladores. Como punto de partida vamos a migrar nuestro estado a Terraform Cloud.

- Collaborate with networking team
- Share information with application teams
- Enable state data access
- Leverage Terraform Cloud for remote state

## Exploring Terraform State

### Terraform State Data

¿Qué es este estado místico de Terraform? Es la asignación de lo que hay en su configuración a los recursos reales que desea administrar.

Los datos de estado se almacenan en formato JSON, y es muy importante que no vaya al lugar donde está almacenado su estado y comience a jugar con el `JSON`. `JSON` es bastante fácil de romper, lo que significa que es bastante fácil estropear lo que sucede en los datos de ese estado, y a Terraform realmente no le gusta eso.

¿Qué hay en esos datos estatales? Además de los metadatos estatales, hay tres tipos de objetos almacenados en recursos estatales, fuentes de datos y salidas.

- Mapping of configuration to actual resources
- Stored in JSON (don't touch!)
- State contents
    - Metadata
    - Resources, data sources, and outputs

Ahora bien, si realmente analizamos la estructura de state data, **los data sources son parte de la lista de recursos**.

```json
{
    // ...
    "resources": [ // resource list
        {
            "mode": "data", // Mode set to data dor a data source
            "type": "aws_availability_zones",
            "name": "available",
            "instances": [{
                "id": "eu-west-3",
                // ....
            }]
        }
    ]
}
```

> They just have their **mode set to data instead of managed**. So really, **it's just two types of objects in state data, `resources` and `outputs`**. 


Cada entrada en la lista de recursos tiene dos o tres elementos que conforman la dirección de ese recurso. Si está en un módulo secundario, habrá una entrada de módulo. A esto le seguirán los campos de tipo de recurso y nombre, y todos ellos combinados forman la dirección del objeto en nuestra configuración. El modo es managed en lugar de los datos, ya que Terraform administra este recurso.

Debido a que puedes crear múltiples instancias de un recurso usando los metaargumentos `count` o `for_each`, hay una lista de instancias, incluso si solo hay una. Dentro de cada instancia estará el campo id que contiene el identificador único del objeto del mundo real que representa el estado, y el resto de los campos son los atributos del objeto y algunos metadatos sobre el objeto para Terraform.

```json
{
    // ...
    "resources": [ // resource list
        {
            "module": "module.main", // Module address
            "mode": "managed", // Mode set to managed for a resource
            "type": "aws_vpc", // Type set to "aws_vpc"
            "name": "this", // Name set to "this"
            "instances": [{ // Instances at the resource address
                "id": "eu-west-3", // ID set to actual resource
                // ....
            }]
        }
    ]
}
```


`Outputs` se almacenan en un mapa con una clave para cada entrada correspondiente al nombre de salida en la configuración. Dentro del mapa para cada salida está el valor y el tipo de valor.

```json
{
    // ....
    "outputs": { // Outputs map
        "vpc_id": { // Output name
            "value": "vpc-123456789", // Value of output
            "type": "string" // Type of output
        }
    }
}
```

Outputs se puede utilizar para compartir información entre equipos.

## Interacting with State Data

HashiCorp has been trying to limit the commands that alter state data to just `apply` and `destroy`, which is basically `apply` with the destroy flag. Each of those commands produce an execution plan before Terraform will make any changes. Commands that change state data directly like `refresh`, `taint`, `untaint`, and `import` are all either deprecated or discouraged from use. Why don't we take a look at some of those commands and see what the replacement is starting with refresh. 

HashiCorp ha estado tratando de limitar los comandos que alteran los datos de estado a simplemente `apply` y `destroy`, que es básicamente `apply` con la `flag` _destroy_. Cada uno de esos comandos produce un plan de ejecución antes de que Terraform realice cambios. Los comandos que cambian el estado de los datos directamente, como "refresh", "taint", "untaint" e "import", están obsoletos o no se recomiendan.

### Terraform Planning Process

Para comprender qué hace el comando `refresh`, primero debemos comprender qué sucede realmente cuando Terraform genera un plan de ejecución.

Cuando Terraform calcula un plan de ejecución, comienza cargando la configuración y los datos de estado en la memoria.

Luego realiza una actualización de los datos de estado de los objetos del mundo real. Terraform tomará nota de cualquier divergencia entre lo que hay en el state data y los valores reales de los recursos gestionados.

Al mismo tiempo, valida la configuración y crea un gráfico de dependencia para todos los objetos. Luego calculará los cambios que deben realizarse en los datos de estado y administrará los recursos para que coincidan con lo que hay en la configuración.

Finalmente, generará un plan de ejecución que contiene los cambios requeridos y cómo alterarán los recursos administrados.

> Página 7 diagrams.drawio

### Refresihng State Data

Si solo desea actualizar los datos de estado para que coincidan con los valores reales de sus recursos administrados, previamente habría utilizado el comando `refresh`. Eso actualizaría los datos de su estado sin generar un plan de ejecución.

Ese comando ha quedado obsoleto. Y a su favor, el método preferido es utilizar el flag `-refresh-only` con el comando `plan` o `apply`.

```bash
# Refresh state data based on managed resources
terraform refresh

# Refresh state data only as part of execution plan
terraform plan -refresh-only

terraform apply -refresh-only
```

Esto le mostrará los cambios de datos estatales propuestos y luego los aplicará con su aprobación. 

### Recreating Resources

Los comandos `taint` y `untaint` se crearon para marcar recursos individuales para la recreación por parte de Terraform, independientemente de su estado actual. Si realmente necesitara recrear una máquina virtual en particular por razones ajenas a Terraform, "marcar" (`taint`) un recurso le indicaría a Terraform que lo destruya y lo vuelva a crear.

Cómo ejemplo de uso: `terraform taint aws_instance.web`. 

`taint` y `untaint` editan el estado directamente. Y si no ejecutamos `apply` inmediatamente, alguien que este trabajando con la configuración actual puede confundirse cuando ejecute `apply`, ya que Terraform ha destruido y recreado un recurso.

En lugar de esto, ahora tenemos el indicador `-replace` para `plan` y `apply`, y eso generará un plan de ejecución que incluye la recreación del recurso identificado.

```bash
# Mark a resource for recreation in state
terraform taint ADDR
terraform taint aws_instance.web

# Replace a resource as part of the execution plan
terraform plan -replace="aws_instance.web"

terraform apply -replace="aws_instance.web"
```

Si estamos en un entorno colaborativo, los datos de estado no se modifican hasta que se ejecuta el plan, por lo que no tenemos que preocuparnos de que alguien más ejecute una solicitud y se confunda seriamente o rompa nuestro flujo de trabajo.

### Moving Resources

`terraform state mv` command. 

```bash
terraform state mv aws_vpc.main aws_vpc.web
```

Este comando está destinado a mover un recurso administrado existente de una dirección en la configuración a otra.

¿Por qué necesitarías hacer eso? Tal vez estés refactorizando tu código y quieras usar un `count` o un bucle `for_each`. Eso cambiaría la dirección de un recurso existente. Lo mismo ocurre con cambiar la etiqueta de nombre de un recurso o mover un recurso a un módulo secundario.

```ini
resource "aws_vpc" "main" {
    cidr_block         = var.vpc_cidr
    enable_dns_support = true

    tags = {
        Name = var.vpc_name
    }
}
```

```ini
resource "aws_vpc" "web" {
    cidr_block         = var.vpc_cidr
    enable_dns_support = true

    tags = {
        Name = var.vpc_name
    }
}
```

> Change **main** to **web**

El comando mv mueve la información del recurso de la dirección antigua a la nueva en los datos de estado. Pero nuevamente, lo hace sin generar un plan de ejecución y también podría arruinar la colaboración.

Entonces, la opción preferida para la mayoría de situaciones es el bloque _moved_. El bloque _moved_ hace lo mismo que el comando MV, pero de forma declarativa como parte de la configuración. El bloque contiene la dirección anterior y la nueva dirección. Cuando ejecuta un plan, Terraform le mostrará el cambio que realizará en los datos del estado. Y cuando ejecuta una solicitud, Terraform moverá el recurso de la dirección anterior a la nueva dirección.

```bash
# Move resources from old to new address
terraform state mv OLD_ADDR NEW_ADDR
terraform state mv aws_vpc.main aws_vpc.web
```

```ini
# Moved block
moved {
    from = OLD_ADDR
    to   = NEW_ADDR
}

moved {
    from = aws_vpc.main
    to   = aws_vpc.web
}
```

El comando `terraform state mv` no está obsoleto porque todavía hay algunos casos extremos en los que el bloque _moved_ no funciona. Pero en su mayor parte, deberías utilizar el bloque _moved_.

### Removing Resources

El único comando que todavía cambia el estado de Terraform directamente y no tiene un reemplazo real es "terraform state rm". `rm` es la abreviatura de eliminar y hace lo que implica.

Le permite eliminar el recurso de los datos estatales. Esto es útil si desea eliminar un recurso de su configuración, pero no desea destruir el recurso real.

Puede usar `terraform state rm` para eliminarlo de los datos de estado y luego eliminar el recurso de su código, y luego Terraform ya no lo administrará.

Al igual que el comando `terraform state mv`, rm no crea un plan de ejecución, simplemente edita directamente los datos de estado.

No hay ningún otro comando o construcción en Terraform que haga esto. Por ahora es lo mejor que tenemos.

```bash
# Remove the resource entry at the given address
terraform state rm ADDR
terraform state rm aws_vpc.main
```

Además de `rm` y `mv` existen otros comandos para la gestión dels estado. 

### Other State Commands

`list`. Esto simplemente enumera todos los recursos almacenados en el state data. Estos son todos sus recursos y fuentes de datos en el módulo raíz y en cualquier módulo secundario. 

```bash
# List all resources and data sources
terraform state list
```

`show` le dará los detalles sobre un recurso específico. Entonces, un flujo de trabajo general podría consistir en ejecutar list primero para obtener los nombres de todos los diferentes recursos en los datos de su estado y luego ejecutar show para obtener las propiedades de un objeto específico. 

```bash
# List all attributes of a single object
terraform state show ADDR
terraform state show aws_vpc.main
```

`pull`, esto simplemente muestra los datos del estado actual en su formato JSON directamente al estándar. Entonces, si tiene algo más que normalmente consume esos datos de estado por algún motivo, tal vez tenga que ir a un registro de auditoría o algo así, este es un comando para extraer esa información de manera elegante. 

```bash
# Send a copy of state data to stdout
terraform state pull
```

You may also be migrating state back ends in a workflow that isn't supported directly by Terraform, so you can pull the current instance of state data from wherever it is and then push it to the new location. But how would you push it? Now there's a `push` command, of course. If you wanted to push a local copy of your state data up to a remote location, you could do that. 

```bash
# Push state data to a path
terraform state push PATH
```

## Running State Commands

[Demo: Running State Comands](./01-running-state-commands/readme.md)

## Terraform State Backends 

Nuestro estado actual se encuentra en un fichero en local. Básicamente existe dos tipos de backend `local` y `remote`.

### Backend Options

Básicamente, si un servicio puede almacenar datos JSON, probablemente podría escribir una implementación de backend para usarlo. 


Sin embargo, eso no significa que todos los backends sean iguales. Hay algunas distinciones importantes entre ellos. Las dos primeras distinciones tienen que ver con las características de Terraform, es decir, `locking` y `workspaces`.

`locking` evita que dos procesos Terraform accedan a datos de estado al mismo tiempo. 

`workspaces` son una forma de utilizar el mismo código para gestionar múltiples entornos. 

No todos backends admiten estas dos características, así que téngalo en cuenta. Las otras dos cosas importantes son el _control de acceso_ y el _cifrado_. Los datos de estado pueden contener información confidencial almacenada en texto plano. 

Probablemente también desee restringir quién tiene acceso a los datos de estado, por lo que probablemente sea una buena idea contar con un conjunto sólido de controles de acceso. Nuevamente, no todos los backends admiten estas funciones, por lo que querrás investigar antes de decidirte por un backend remoto en particular.

- Local backend
    - Default setting
- Remote backend
    - S3, Azure Storage, Google Cloud Storage
    - Terraform Cloud and Consul
- Features
    - Locking
    - Workspaces
- Data encryption
- Access control

### Backend Block

Cuando decida que desea utilizar un nuevo backend remoto, debe definirlo e inicializarlo. Si recuerdas cuando ejecutamos `terraform init` al comienzo de una configuración, una de las cosas que dice es que está inicializando el backend. Y si no ha especificado un backend, utilizará el backend del archivo local de forma predeterminada.

Pero si desea utilizar un bakend remoto, debe configurarlo. Aquí está la sintaxis del bloque de configuración del backend.

```ini
terraform {
    backend "backend_type" {
        IDENTIFIER = VALUE
    }
}
```

```ini
# S3 example
terraform {
    backend "s3" {
        bucket         = "state-12345"
        key            = "dev/network/terraform.tfstate"
        dynamodb_table = "state-12345"
        region         = "eu-west-3"
        access_key     = "HTSDIUS898DSD"
        secret_key     = "yysduy&**hgdktj7898YTUIk000"
    }
}
```

Los valores en el bloque backend no pueden usar interpolación. ¿Qué significa eso? Significa que no puede usar variables de entrada o valores locales en su configuración de backend. Y la razón es que Terraform ni siquiera ha evaluado sus variables en las locales cuando inicializa el backend. Algunas configuraciones, como la clave de acceso, la clave secreta y la región, pueden obtenerse de variables de entorno. 

```ini
# S3 example
terraform {
    backend "s3" {
        bucket         = "state-12345"
        key            = "dev/network/terraform.tfstate"
        dynamodb_table = "state-12345"
    }
}
```

### Partial Configuration

We can pass values through the init command in line with the backend config flag repeated for each value that we want to pass in. Or we can put our values in a text file similar to a Terraform dot TFV file and pass it in using the backend config flag with the path to our file. 

Podemos pasar valores a través del comando `init` en línea con el indicador de configuración del backend repetido para cada valor que queremos pasar. O podemos poner nuestros valores en un archivo de texto similar a un archivo terraform.tfv y pasarlo usando el _backend config flag_ con la ruta a nuestro archivo.

```ini
terraform {
    backend "s3" {}
}
```

```bash
# Using in-line settings
terraform init -backend-config="bucket=state-12345"

# Using a backend config file
terraform init -backend-config="backend-settings.txt"
```

## Backend Planning and Prerequisites

Terraform Cloud puede almacenar sus datos de estado y organizar ejecuciones de Terraform. También proporciona muchas otras características. Pero el objetivo principal del uso de Terraform Cloud es el almacenamiento de datos de estado y la automatización del flujo de trabajo. Vamos a configurar Terraform Cloud y luego preparar nuestra configuración para usar Terraform Cloud como backend remoto.

[Demo: Terraform Cloud Set Up](./02-terraform-cloud-setup/readme.md)

## Cloud Block Syntax and Setup

Terraform Cloud puede utilizar el bloque backend como todos los demás backends remotos. Pero en Terraform 1.2, HashiCorp introdujo el bloque de cloud alternativo. Incluye algunas funciones adicionales que no están presentes en el bloque backend, por lo que usaremos esta en su lugar.

La sintaxis es el bloque de cloud sin etiquetas de bloque. Dentro del bloque hay un argumento para el nombre de su organización y un bloque de espacio de trabajo anidado que puede tomar un nombre de espacio de trabajo o una lista de etiquetas para administrar y crear múltiples `workspaces`.

A diferencia del bloque backend, no puedes utilizar una configuración parcial con el bloque de cloud. Debe proporcionar todos los valores del bloque.

```ini
terraform {
    cloud {
        organization = "bootcamp-jsz"

        workspaces {
            name = "web-network-dev"
        }
    }
}
```

[Demo: Using Terraform Cloud for State](./03-using-terraform-cloud/readme.md)

## Migrating State Data

Migrar datos de estado de Terraform es notablemente simple. No es nada complicado. Lo primero que debe hacer es actualizar la configuración de su backend. Eso ya lo hicimos. Tienes que decirle, como vimos en el ejemplo, dónde colocar los datos en el nuevo backend.

Y una vez que haya actualizado la configuración, deberá volver a ejecutar terraform init. Está reiniciando su configuración y verá, oh, hay un nuevo backend aquí y tengo datos de estado existentes almacenados en el backend anterior. Luego le preguntará si desea migrar sus datos estatales existentes a esta nueva ubicación. Generalmente la respuesta va a ser sí, por lo que simplemente tendremos que confirmar el estado de migración. Copia todos los datos de local a remoto. Y eso es.

- Update configuration with backend or cloud block
- Run terraform init with any required flags
- Confirm state data migration

[Demo: Migrating State Data](./04-migrating-state-data/readme.md)

## Summary

Primero, establecimos que el estado de Terraform es algo importante. Es algo muy importante. Debes tener cuidado con él y colocarlo en un lugar protegido y accesible para otros miembros del equipo. Analizamos las diferentes formas en que puede alterar los datos de estado usando Terraform y algunos de los comandos obsoletos. Ya sean comandos obsoletos o nuevos procesos declarativos, el punto principal es que no toca los datos de estado JSON directamente. Hágalo a través de la CLI porque sabe lo que está haciendo.

En términos generales, es preferible almacenar los datos de su estado de forma remota. Lo hace más seguro. Si su computadora de escritorio o portátil falla, no perderá todos los datos de su estado y podrá colaborar con otras personas.

- Terraform state is kinda important
- Decalarative state management
- Remote state for security and collaboration
