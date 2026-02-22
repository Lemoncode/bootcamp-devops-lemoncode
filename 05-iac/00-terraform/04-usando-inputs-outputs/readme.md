# Usando Input Variables y Outputs

Vamos a ir haciendo mejoras de manera progresiava sobre nuestro despliegue, aprovechando las `input varaibles` y los `outputs` que nos ofrece Terraform.

* Quitar las credenciales de AWS.
* Reemplazar los hard coded values.
* Etiquetas para compañia, proyecto y facturación.
* Generar el output del hostname DNS público.

## Añadiendo variables a la configuración

[Añadiendo variables a la configuración - Demo 02](02-demo.md)

## Locals

> Valores evaluados dentro de la configuración, no puedes asignar su valor de forma directa, como las variables.

Puedes tener múltiples entradas `locals`, pero sus pares `key/value` han de ser únicos.

[Añadiendo Locals a la configuración - Demo 03](03-demo.md)

## Outputs

Los `output values` es como sacar información de Terraform.

[Añadiendo Outputs a la configuración - Demo 04](04-demo.md)

## Validar la configuración

Antes de aplicar nuestros cambios, sería estupendo poder validar que la configuración es sintacticamente correcta.

[Usando Validate - Demo 05](05-demo.md)

## Desplegando la Configuración Actualizada

[Desplegando la Configuración Actualizada - Demo 06](06-demo.md)

## Variables vs Locals

Para aclarar, en Terraform los `locals` y `variables` sirven a propositos distintos. Las `variables` son entradas externas, y los `locals` calculan valores a nivel de módulo. 

| Aspect     | Variables                                                                  | Locals                                                                                     |
| ---------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Scope      | Global or module input; can be passed between modules                      | Module-only; not accessible outside the defining module spacelift+1                        |
| Assignment | Set externally (e.g., CLI, tfvars files, defaults); no expressions allowed | Defined internally via expressions, functions, or other values; fixed once set spacelift+2 |
| Mutability | Overridable at runtime                                                     | Immutable after definition; used for reuse without repetition spacelift+1                  |
| Use Case   | Dynamic inputs from users/environments                                     | Data transformation, constants, reducing duplication (e.g., tags, computed names) reddit+1 |
