# Tipos de Datos

**Groovy** es un lenguaje con tipado opcional, lo que significa que podemos trabajar con tipos `primitivos de Java`, o podemos dejar que el `runtime` los deduzca del contexto, lo cuál lo hace bastante bien.

- `x` es claramente un número
- Un lenguaje opcionalmente tipado
- Sin ninguna definición de tipo

Veamos cuales son los tipo primitivos que vamos a utilizar:

| Data Type | Groovy Keyword | Sample Data   |
| --------- | -------------- | ------------- |
| Strings   | String         | "Jaime Salas" |
| Integers  | int            | 0, 1, 2, 3    |
| Floats    | float          | 0.5, 3.8      |
| Boolean   | Boolean        | true, false   |

# Demo: Tipos de Datos

Creamos el siguiente fichero [01_groovy_data_types.groovy](playground/01_groovy_data_types.groovy)

```groovy
String name = "Joe Doe"
int courseCount = 14
float salary = 999999.99
Boolean isProgrammer = true

println name + " has created " + courseCount + " courses." // [1]
println name + " is a programmer? " + isProgrammer // [1]
println name + " wishes his salary was " + salary // [1]
```

1. Groovy convierte los `booleans` y `float` a `strings`

Y lo podemos ejecutar de la siguiente manera:

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 01_groovy_data_types.groovy
Joe Doe has created 14 courses.
Joe Doe is a programmer? true
Joe Doe wishes his salary was 1000000.0
```

Vamos a introducir una pequeña diferencia

```diff
String name = "Joe Doe"
int courseCount = 14
float salary = 999999.99
Boolean isProgrammer = true

println name + " has created " + courseCount + " courses."
-println name + " is a programmer? " + isProgrammer
+println name + " is a programmer? " + isProgrammer.toString().capitalize()
println name + " wishes his salary was " + salary
```

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 01_groovy_data_types.groovy
Joe Doe has created 14 courses.
Joe Doe is a programmer? True
Joe Doe wishes his salary was 1000000.0
```

Podemos notar que `Groovy` tiene un problema al convertir de `float` a `string`, podemos tener un control más fino usando el formateo de `String`.

```diff
String name = "Joe Doe"
int courseCount = 14
float salary = 999999.99
Boolean isProgrammer = true

println name + " has created " + courseCount + " courses."
println name + " is a programmer? " + isProgrammer.toString().capitalize()
-println name + " wishes his salary was " + salary
+println name + " wishes his salary was \$" + String.format("%.2f", salary)
```

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 01_groovy_data_types.groovy
Joe Doe has created 14 courses.
Joe Doe is a programmer? True
Joe Doe wishes his salary was $1000000.00
```

Seguimos teniendo un problema, simplemente podemos cambiar el tipo:

```diff
String name = "Joe Doe"
int courseCount = 14
-float salary = 999999.99
+BigDecimal salary = 999999.99
Boolean isProgrammer = true

println name + " has created " + courseCount + " courses."
println name + " is a programmer? " + isProgrammer.toString().capitalize()
-println name + " wishes his salary was \$" + String.format("%.2f", salary)
+println name + " wishes his salary was \$" + salary
```

Simplemente como nota en `Java` tenemos `;` para terminar una línea, en `Groovy` son opcionales.

### Tipos de Datos y Sintaxis

- "def" opcional o tipo de dato explicito
- ¿Perder el tipado? Nop
- Cuando devolvemos un valor está perfectamente claro el tipo devuelto
