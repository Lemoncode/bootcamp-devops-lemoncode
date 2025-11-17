# Trabajando con recursos existentes

## Introducción

There is a really good chance that when you're first deploying Terraform, there are going to be some existing resources out there that you might want to bring into the management realm of Terraform, and that's what this module is going to be dealing with. 

- Greenfield es la excepción
- Opciones de importación con Terraform
    - Import command
    - Import block

## Entorno 

### Entorno Existente

> TODO: Add diagram

Echemos un vistazo al entorno existente anterior al uso de Terraform. Entonces, el entorno actual utiliza una "VPC" que está ubicada en eu-west-3, también conocida como París, y tiene un rango CIDR de "10.42.0.0/16". Ahora, como ya sabrá, una región en AWS se divide en múltiples zonas de disponibilidad.

Dentro del VPC, nos ocuparemos de tres de esas zonas de disponibilidad, eu-west-3a, 3b y 3c. Actualmente, tienen subredes implementadas en dos de esas zonas de disponibilidad. Tiene dos subredes públicas que utilizan 10.42.10.0/24 y 10.42.11.0/24.

Ese es el entorno actual que queremos empezar a gestionar utilizando Terraform.

## Reviewing the Network Configuration

Abrir `cloud-formation-template/vpc_template.yaml` 

Al desplazarnos hasta el principio del archivo, tenemos los parámetros para esta plantilla junto con los valores predeterminados.

```yaml
Parameters:
  EnvironmentName:
    Description: An environment name that is prefixed to resource names
    Type: String

  VpcCIDR:
    Description: Please enter the IP range (CIDR notation) for this VPC
    Type: String
    Default: 10.42.0.0/16

  PublicSubnet1CIDR:
    Description: Please enter the IP range (CIDR notation) for the public subnet in the first Availability Zone
    Type: String
    Default: 10.42.10.0/24

  PublicSubnet2CIDR:
    Description: Please enter the IP range (CIDR notation) for the public subnet in the second Availability Zone
    Type: String
    Default: 10.42.11.0/24
```

Después de los Parámetros están los recursos que realmente estamos creando. Está la VPC en sí, una puerta de enlace de Internet para manejar el tráfico saliente desde las subredes públicas y un recurso adjunto que conecta la puerta de enlace de Internet con la VPC. 

```yaml
Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCIDR
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: !Ref EnvironmentName

  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: !Ref EnvironmentName
```

Luego tenemos nuestras dos subredes públicas, seguidas de una RouteTable para esas subredes. A la RouteTable, agregaremos una ruta predeterminada para enviar tráfico a InternetGateway y luego asociaremos esa RouteTable con nuestras dos subredes públicas. 

```yaml
DefaultPublicRoute:
    Type: AWS::EC2::Route
    DependsOn: InternetGatewayAttachment
    Properties:
      RouteTableId: !Ref PublicRouteTable
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref InternetGateway
```

Finalmente, en la parte inferior, hay un NoIngressSecurityGroup que bloquea todo el tráfico de entrada. 

```yaml
NoIngressSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: "no-ingress-sg"
      GroupDescription: "Security group with no ingress rule"
      VpcId: !Ref VPC
```

Esos son todos los recursos que creará la plantilla de CloudFormation. Para importar esos recursos a Terraform, necesitaremos los ID de cada recurso, y esos están representados en los resultados. 

```yaml
Outputs:
  VPC:
    Description: A reference to the created VPC
    Value: !Ref VPC

  PublicSubnet1:
    Description: A reference to the public subnet in the 1st Availability Zone
    Value: !Ref PublicSubnet1
# ....
```

Tomaremos los resultados y los guardaremos en un archivo de texto para facilitar su consulta. Ahora que hemos revisado la plantilla, implementémosla en AWS. 

[Demo: Deploying Template](./01-deploying-template/readme.md)

## Import Command

Terraform tiene dos procesos integrados para importar recursos existentes a Terraform. Examinaremos cada uno y compararemos las dos opciones. 

### The Import Command

La primera opción es utilizar el comando de `import` de Terraform. El comando toma dos argumentos, una dirección abreviada como ADDR y el identificador del recurso, abreviado ID. 

```bash
# Command syntax
terraform import [options] ADDR ID

# ADDR - configuration resource identifier
# Ex. - aws_vpc.main

# ID - provider specific resource identifier
# Ex. vpc-123456789
```

La dirección es una referencia a un bloque de configuración de recursos en su código Terraform y toma la forma de un tipo de recurso que pone un punto en la etiqueta del nombre.

El identificador es el ID único del recurso en el entorno de destino y ese identificador es específico del tipo de recurso.

Pero, ¿cómo se puede saber cuál debería ser ese identificador? Si saltamos a la documentación del proveedor de AWS y miramos el recurso de VPC, en la parte inferior habrá una sección Importar. 

- [vpc import](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#import)

Esa sección nos dice que el identificador único es el ID de VPC. Cualquier recurso que pueda importarse incluirá una sección de importación en la documentación. Y no todos los recursos se pueden importar, pero la mayoría sí.

Entonces, si importáramos una VPC existente a nuestra configuración de Terraform, el comando podría verse como terraform import aws_vpc.main para la dirección en nuestra configuración y vpc‑123654789 para el identificador de la VPC y AWS.

```bash
# Importing a vpc into a configuration
terraform import aws_vpc.main vpc-123456789
```

¿Cuál es el proceso real para usar el comando de importación? Vamos a ver. Cuando ejecuta el comando de importación de terraform, Terraform simplemente actualiza los datos de estado con una nueva entrada. Se trata de agregar el recurso al estado en la dirección que especifique y completar el recurso con atributos del recurso real en su entorno de destino.

```json
// terraform.tfstate
{
    "resources": [
        {
            "mode": "managed",
            "type": "aws_vpc",
            "name": "main",
            "instances": [
                "id": "vpc-123456789"
            ]
        }
    ]
}
```

Ahora sabes que en realidad no agrega el bloque de recursos a tu código y eso depende de ti. Para cada recurso que desee agregar, deberá agregar un bloque de recursos a su código y completarlo con argumentos que coincidan con los atributos existentes del recurso en su entorno de destino.

```ini
resource "aws_vpc" "main" {
    cidr_block         = var.vpc_cidr
    enable_dns_support = true

    tags = {
        Name = var.vpc_name
    }
}
```

Luego ejecuta un "terraform plan" y ve si es necesario realizar algún cambio. 

```bash
terraform plan
```

Si ha hecho todo correctamente, no debería ver cambios. Si ve que se requieren cambios, deberá actualizar su código e intentarlo nuevamente hasta que no sea necesario realizar cambios.

Este es el proceso anterior de importar recursos usando el comando de importación. Terraform 1.5 introdujo un proceso declarativo que utiliza el bloque de importación. Echemos un vistazo a eso.

## Import Block and Comparison

En lugar de utilizar un comando para importar recursos, Terraform 1.5 introdujo un nuevo bloque de configuración llamado `import block`. La sintaxis del bloque es increíblemente sencilla.

La palabra clave es "import" y no requiere ninguna etiqueta. Dentro del bloque hay dos argumentos. El argumento to es similar a la "address" en el comando de importación, y el argumento "id" es similar al identificador en el comando de importación.

```ini
import {
    to = address
    id = identifier
}
```

Puede declarar varios bloques de importación en su código y cada uno importará un único recurso.

```ini
import {
    to = "aws_vpc.main"
    id = "vpc-123456789"
}

import {
    to = "aws_subnet.subnet1"
    id = "subnet-123456789"
}

import {
    to = "aws_subnet.subnet2"
    id = "subnet-789612345"
}

```

En cuanto a los bloques de configuración de recursos que se encuentran en las dos direcciones, tienes dos opciones. Puede agregar el bloque de recursos usted mismo o puede hacer que Terraform intente generar el bloque por usted. ¿Cómo es ese proceso?

Una vez que haya agregado sus bloques de importación, ejecutará `terraform plan`. Si desea que Terraform intente generar los bloques de recursos por usted, agregará el argumento `generate‑config‑out` y lo establecerá en una ruta de archivo donde se deben generar los bloques.

```bash
terraform plan -generate-config-out=generated.tf
```

```ini
# imports.tf
import {
    to = "aws_vpc.main"
    id = "vpc-123456789"
}
```

```ini
# generated.tf
# __generated__ by Terraform from...
resource "aws_vpc" "main" {
    cidr_block         = "10.42.0.0/16"
    enable_dns_support = true

    tags = {
        Name = "globo-web-app"
    }
}
```

Actualmente es una característica experimental, así que no se sorprenda si hay algún problema con el bloque de configuración generado.

Si no agrega ese argumento, Terraform simplemente le dirá cuando ejecute `terraform plan` que faltan bloques de recursos.

De cualquier manera, cuando ejecute un `terraform plan`, Terraform hará lo que siempre hace: le mostrará los cambios que planea realizar en sus datos de estado y en el entorno de destino.

```ini
# main.tf
import {
    to = "aws_vpc.main"
    id = "vpc-123456789"
}

resource "aws_vpc" "main" {
    cidr_block         = var.vpc_cidr
    enable_dns_support = true

    tags = {
        Name = var.vpc_name
    }
}
```

Si ha hecho todo correctamente, debería tener un plan para importar los nuevos recursos sin cambiarlos.

```bash
terraform plan

Terraform will perform the following actions:

...

Plan: 1 to import, 0 to add, 0 to change, 0 to destroy
```

Si ve que se requieren cambios, deberá actualizar su código e intentarlo nuevamente hasta que no sea necesario realizar cambios. Es algo así como el comando de importación.

Cuando esté listo para importar el recurso, ejecutará "terraform apply" y se importarán los recursos.

```bash
terraform apply

...

Apply complete! Resources: 1 imported, 0 added, 0 changed, 0 destroyed
```

### Choosing an Import Process

Entonces, ¿por qué elegirías uno sobre el otro? El bloque de importación se introdujo para solucionar varias deficiencias del comando de importación.

En primer lugar, el comando de importación edita directamente los datos de estado sin ningún plan de ejecución que revisar. HashiCorp ha estado intentando reducir cualquier edición directa de datos estatales, y el bloque de importación es un paso en esa dirección.

En segundo lugar, el comando de importación solo le permite importar un único recurso a la vez. Si tiene, digamos, 100 recursos o 1000 recursos, tendrá que agrupar esos comandos de importación y esperar mientras se ejecuta cada uno, y espero que no haya estropeado nada. El bloque de importación le permite importar tantos recursos como desee al mismo tiempo y mostrará errores durante el plan antes de realizar cambios en el estado.

En tercer lugar, el comando de importación no crea la configuración por usted. Ahora bien, aunque por el momento es una característica experimental, permitir que Terraform cree los bloques de configuración para sus recursos ayuda a ahorrar tiempo y reduce la barrera de entrada.

Por todas estas razones, el bloque de importación será el método preferido para importar recursos a Terraform. Y el comando de importación seguirá estando disponible, al menos hasta la versión principal uno, pero estoy seguro de que quedará obsoleto en algún momento en el futuro.

|         Import command         |        Import block        |
|:------------------------------:|:--------------------------:|
|    Directly edits state data   |   Produces execution plan  |
|    Single resource at a time   |     Multiple resources     |
|  Create configuration manually | Terraform generated blocks |
| Supported at least trough v1.X |      Preferred method      |


### Current Gaps

También quiero reconocer que todavía existen algunas lagunas en ambos enfoques. En primer lugar, Terraform no descubre ni cataloga dinámicamente sus recursos existentes. Eso depende de ti. Tenemos una buena tabla que fue producida por CloudFormation, pero no siempre la tendrás. El proceso de descubrimiento sigue siendo su responsabilidad.

En segundo lugar, los bloques de recursos generados por Terraform son completamente literales. Cada atributo se copia tal cual del recurso existente y depende de usted agregar referencias dinámicas y variables de entrada. Terraform no hará eso por usted, como veremos en un momento.

- No dynamic discovery of existing infrastructure
- Generated resource configuration blocks are literal

Esos son dos de los grandes problemas con el enfoque actual, pero HashiCorp trabaja constantemente para mejorar la funcionalidad de importación, y algunas de estas brechas pueden haberse solucionado cuando vea esto, así que siempre consulte la documentación para obtener la información más reciente.

## Reviewing the Example Network Configuration

[Demo: Reviewing the Example Network Configuration](./32-demo.md)

## Adding the Import Blocks

[Demo: Adding the Import Blocks](./33-demo.md)

## Running the Import Process

[Demo: Running the Import Process](./34-demo.md)


## Summary

All right, what did we cover in this module? Well, this module was all about importing resources because Brownfield really is the norm when it comes to using Terraform. You're going to walk into an environment that already has resources deployed, and we saw how we can take some of that existing infrastructure and get it imported into Terraform, whether we're using modules or not. 

In a more complicated situation, the process might be a little bit longer and have several more wrinkles than what we saw in the demo. The nice thing is that you don't have to do it all at once. You can gradually import resources and do so across more than one configuration. 

Although Terraform won't build out a full configuration, the generate‑config‑out option gives you a starting point for resources, and then you can refactor that code without altering the managed resources. 

Now coming up in the next module, we are going to get into managing state data. So far, our state has been stored in a local file. But if we want all of Globomantics to get on the Terraform train, we need to move that state to a remote location for collaboration and security.