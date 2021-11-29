# Subrutinas

En `Groovy` existen dos tipos de subrutinas. Funciones y métodos.

Las funciones devuelven un valor, los métodos no. Algunos lenguajes hacen una fuerte diferenciación entre ambos tipos, pero `Groovy`, como `Java` y `C#`, simplemente define un método como una función devolviendo el tipo `void`.

Imaginemos que en nuestros procesos de build, necesitamos generar credenciales para los usuarios. Queremos crear un nombre de usuario simple usando la primera letra del nombre más el apellido, de esta manera los usuarios tendrán un nombre de usuario único.

Nuestra segunda función va a ser un función que imprima los nombres por consola.

- Funciones
- Métodos
- Groovy, Java y C#: void return type
- Una función para crear credenciales desde el nombre

# Demo: Subrutinas

Crear un nuevo fichero [03_groovy_subroutines](playground/03_soubroutines.groovy)

Vamos a comenzar una aseveración sencilla

```groovy
assert getUserName("Jaime", "Salas") == "jsalas" : "getUserName isn't working"
```

```groovy
/*diff*/
String getUserName(String firstName, String lastName) {
    return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
}
/*diff*/

assert getUserName("Jaime", "Salas") == "jsalas" : "getUserName isn't working"
```

Lo podemos ejecutar con `docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 03_subroutines.groovy`, nos devuelve **null** indicando que el resultado es correcto.

Imprimimos el valor a la consola para hacerlo un poco más claro:

```diff
String getUserName(String firstName, String lastName) {
    return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
}

assert getUserName("Jaime", "Salas") == "jsalas" : "getUserName isn't working"

+println(getUserName("Jaime", "Salas"))
```

Ahora creamos un método que imprima las credenciales

```groovy
String getUserName(String firstName, String lastName) {
    return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
}

assert getUserName("Jaime", "Salas") == "jsalas" : "getUserName isn't working"

println(getUserName("Jaime", "Salas"))

/*diff*/
void printCredentials(cred) {
    println("UserName is ${cred}")
}

printCredentials(getUserName("Jaime", "Salas"))
/**/
```

Después de ejecutar, tenemos

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 03_subroutines.groovy
jsalas
UserName is jsalas
```

Vamos a modificar esto para trabajar con arrays de `names` y `lastnames`

```diff
String getUserName(String firstName, String lastName) {
    return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
}

assert getUserName("Jaime", "Salas") == "jsalas" : "getUserName isn't working"

-println(getUserName("Jaime", "Salas"))

void printCredentials(cred) {
    println("UserName is ${cred}")
}

-printCredentials(getUserName("Jaime", "Salas"))

+String[] firstNames = ["Ferra", "Dani", "Jordi", "Joan", "Martin"]
+String[] lastNames = ["Adriá", "García", "Cruz", "Roca", "Berasategi"]
+
+for (int i = 0; i < firstNames.size(); i++) {
+   printCredentials(
+       getUserName(firstNames[i], lastNames[i])
+   );
+}
```

Después de ejecutar, tenemos

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 03_subroutines.groovy
UserName is fadriá
UserName is dgarcía
UserName is jcruz
UserName is jroca
UserName is mberasategi
```
