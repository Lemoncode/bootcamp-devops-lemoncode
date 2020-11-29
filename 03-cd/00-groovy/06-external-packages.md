# Trabajando con paquetes externos

En este punto, ya deberíamos tener una base para crear scripts en `Groovy`. Pero nos falta una última pieza, el proceso de interactuar con paquetes externos.

* Paquetes externos
* Nos permiten acceder al trabajo de otros desarrolladores.

La realidad es que ya tenemos de forma automática ciertos paquetes con `Groovy`, la realidad es que no los podemos llamar realmente externos porque siempre van a estar incluidos. Todo script de `Groovy` importa los siguientes paquetes.

| java.io.* | java.lang.* | java.math.BigDecimal | java.math.BigInteger |
|:---------:|:-----------:|----------------------|----------------------|
|  java.net |  java.util  |     groovy.lang.*    |     groovy.util.*    |


Esto es equivalente a tener los siguientes imports en nuestro script

```groovy
import java.lang.*
import java.util.*
import java.io.*
import java.net.*
import groovy.lang.*
import groovy.util.*
import java.math.BigInteger
import java.math.BigDecimal
```

Casi siempre que comenzamos a trabajar terminamos necesiatndo alguno de estos.


# Demo: Trabajando con paquetes externos

Crear el siguiente fichero [06_working_with_external_packages.groovy](playground/06_working_with_external_packages.groovy)

```groovy
String filePath = "/home/groovy/scripts/chef.json";

def jsonSlurper = new JsonSlurper()
ArrayList data = jsonSlurper.parse(new File(filePath));

println(data.getClass())

for (chef: data) {
    
    println(chef.name);
    for (restaurant: chef.restaurants) {
        println('\t' + restaurant.name)
    }
}
```

Si ejecutamos esto ahora obtenemos el siguiente mensaje: `3: unable to resolve class JsonSlurper`

```diff
+import groovy.json.JsonSlurper
+
String filePath = "/home/groovy/scripts/chef.json";
...
```