# Estructuras de Control

Para hacer algo medianamente importante en nuestros scripts, necesitamos estructuras de control. La más esencial de ellas es `if else`, que tiene la misma apariencia que en `Java` on en `C`

```groovy
if (isProgrammer) {
    println "He's a programmer, alright"
}
else {
    println "Not a programmer, tho"
}
```

Lo mismo para un `loop`

```groovy
for (int i = 0; i < courseCount; i++) {
    println "Chris made course " + (i + 1) + "!!!"
}
```

Lo mismo de cun un `while loop`

```groovy
int i = 0;

while (i < courseCount) {
    println "Chris made course " + (i + 1) + "!!!"
    i++
}
```

Podemos definir un `for in loop` de la siguiente manera:

```groovy
String[] singers = ["Bob", "George", "Jeff", "Roy", "Tom"]

for(String singer: singers) {
    println singer
}
```

Podemos definir el bucle anterior de una manera más compacta:

```groovy
singers.each({ x -> println(x) })
```

Podemos incluso darle una vuelta de tuerca más alimentando directamente el `iterador`.

```groovy
singers.each({ println(it) })
```

# Demo: Estructuras de Control

Crear el siguiente el fichero [02_control_structures.groovy](playground/02_control_structures.groovy)

```groovy
int courseCount = 14;
Boolean isProgrammer = true;
String[] singers = ["Bob", "George", "Jeff", "Roy", "Tom"]

if (isProgrammer) {
    println "He's a programmer"
}
else {
    println "not a programmer"
}

for (int i = 0; i < courseCount; i++) {
    println "Chris made course " + (i + 1) + "!!!"
}

for (String singer: singers) {
    println singer
}

singers.each(x -> println(x))
singers.each{println(it)}
```

Y lo ejecutamos de la siguiente manera:

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 02_control_structures.groovy
He's a programmer
Chris made course 1!!!
Chris made course 2!!!
Chris made course 3!!!
Chris made course 4!!!
Chris made course 5!!!
Chris made course 6!!!
Chris made course 7!!!
Chris made course 8!!!
Chris made course 9!!!
Chris made course 10!!!
Chris made course 11!!!
Chris made course 12!!!
Chris made course 13!!!
Chris made course 14!!!
Bob
George
Jeff
Roy
Tom
Bob
George
Jeff
Roy
Tom
```
