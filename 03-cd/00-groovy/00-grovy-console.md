# The Groovy Console

Lo primero que necesitamos para trabajar con cualquier tipo de lenguajes es algo que valide y verifique que nuestro código se comporta de la manera que nsostros esperamos.

Nuestro objetivo final será `Jenkins`. Como nota al respecto, `Jenkins` tiene internamente, una consola de `Groovy` para validar de los `scripts`. Pero para desarrollar nos puede convenir una solución más ligera.

`Apache`, tiene una herramienta como la que necesitamos [link](http://groovy-lang.org/download.html). Esta aplicación es una aplicación de `swing`.

- Algo para verificar y validar nuestro código.
- Nuestro objetivo es `Jenkins`.
- Un sitio para experimentar.

Una alternativa a instalar de manera local, es utilizar un [contenedor de Docker](https://hub.docker.com/_/groovy?tab=description)

```bash
docker run -it --rm groovy

# Running a Groovy script
docker run --rm -v "$PWD":/home/groovy/scripts -w /home/groovy/scripts groovy groovy <script> <script-args>
```

> Referencia: https://groovy-lang.gitlab.io/101-scripts/docker/basico-en.html

Crear `BasicDocker.groovy`

```groovy
println "------------------------------------------------------------------"
println "Hello"
System.getenv().each{
    println it
}
println "------------------------------------------------------------------"
```

Ahora desde el directorio raíz en el cual hemos creado el fichero anterior, podemos ejecutar:

```bash
docker run --rm -v "$PWD":/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy BasicDocker.groovy
```

- `--rm` elimina el contenedor cuando esté parado.
- `-v` enlazamos el directorio en el que nos encontramos a `/home/groovy/scripts` dentro del contenedor.
- `-w` establecemos el directorio de trabajo dentro del contenedor a `/home/groovy/scripts`.

# Demo: La Consola de Groovy

- Create `playground/00_groovy_console.groovy`

```groovy
def x = 5

x += 5

println x
assert x == 10
```

Y lo podemos ejecutar de la siguiente manera:

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 00_groovy_console.groovy
$ 10
```

Si cambiamos el valor de `x`

```diff
def x = 5

x += 5

println x
-assert x == 10
+assert x == 11
```

Podemos introducir un mensaje si la aseveración no pasa.

```diff
def x = 5

x += 5

println x
-assert x == 11
+assert x == 11: "Value was not eleven"
```

```bash
Jaimes-MacBook-Pro:playground jaimesalaszancada$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 00_groovy_console.groovy
10
Caught: java.lang.AssertionError: Value was not eleven. Expression: (x == 11). Values: x = 10
java.lang.AssertionError: Value was not eleven. Expression: (x == 11). Values: x = 10
        at 00_groovy_console.run(00_groovy_console.groovy:7)
```
