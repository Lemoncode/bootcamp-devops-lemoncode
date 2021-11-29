# Working with Classes and Objects

Con las subrutinas ya tenemos una primera base para la encapsulación. Pero desde luego que vamos a necesitar más, y ahí entran las clases. En nuestro ejemplo anterior teníamos dos listas paralelas de nombres. Esto se sin duda algo que queremos tener en una clase con dos propiedades, así no nos tenemos que preocupar de tener dos arrays del mismo tamaño, y cosas por el estilo.

Para crear una clase simplemente usamos `class`.

- Nivel base para la encapsulación
- Envolvemos nuestro código en clases
- Listas paralelas => objectos con dos propiedades
- Muy similar a `Java` o `C#`

```groovy
class User {
    // code and do stuff
}

User user = new User();
```

# Demo: Trabajando con Clases y Objetos

Creamos el siguiente fichero [04_working_with_classes_and_objects.groovy](playground/04_working_with_classes_and_objects.groovy)

> Nota: Comenzamos desde el código de la demo anterior.

```groovy
String getUserName(String firstName, String lastName) {
    return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
}

assert getUserName("Jaime", "Salas") == "jsalas" : "getUserName isn't working";

void printCredentials(cred) {
    println("UserName is ${cred}")
}

String[] firstNames = ["Ferra", "Dani", "Jordi", "Joan", "Martin"]
String[] lastNames = ["Adria", "Garcia", "Cruz", "Roca", "Berasategi"]

for (int i = 0; i < firstNames.size(); i++) {
   printCredentials(
       getUserName(firstNames[i], lastNames[i])
   );
}
```

```groovy
/*diff*/
class User {
    String lastName;
    String firstName;
}
/*diff*/

String getUserName(String firstName, String lastName) {
    return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
}

assert getUserName("Jaime", "Salas") == "jsalas" : "getUserName isn't working"

void printCredentials(cred) {
    println("UserName is ${cred}")
}

String[] firstNames = ["Ferra", "Dani", "Jordi", "Joan", "Martin"]
String[] lastNames = ["Adria", "Garcia", "Cruz", "Roca", "Berasategi"]

for (int i = 0; i < firstNames.size(); i++) {
    printCredentials(
        getUserName(firstNames[i], lastNames[i])
    );
}
```

Podemos ejecutarlo para verificar que el código es correcto.

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 04_working_with_classes_and_objects.groovy
UserName is fadria
UserName is dgarcia
UserName is jcruz
UserName is jroca
UserName is mberasategi
```

Ok vamos a refactorizar un poco nuestro código

```diff
class User {
    String lastName;
    String firstName;
+
+   public String UserName() {
+       return getUserName(this.firstName, this.lastName);
+   }
+
+    private String getUserName(String firstName, String lastName) {
+        return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
+    }
}

-String getUserName(String firstName, String lastName) {
-    return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
-}

-assert getUserName("Jaime", "Salas") == "jsalas" : "getUserName isn't working"

-void printCredentials(cred) {
-    println("UserName is ${cred}")
-}

String[] firstNames = ["Ferra", "Dani", "Jordi", "Joan", "Martin"]
String[] lastNames = ["Adria", "Garcia", "Cruz", "Roca", "Berasategi"]

-for (int i = 0; i < firstNames.size(); i++) {
-    printCredentials(
-        getUserName(firstNames[i], lastNames[i])
-    );
-}
+
+for (int i = 0; i < firstNames.size(); i++) {
+   User u = new User(firstName: firstNames[i], lastName: lastNames[i]);
+   println("UserName is ${u.UserName()}")
+}

```

Comprobemos que está funcionando. Por último quitemos los dos arrays y creamos un único array de usuarios:

```diff
class User {
    String lastName;
    String firstName;

    public String UserName() {
        return getUserName(this.firstName, this.lastName);
    }

    private String getUserName(String firstName, String lastName) {
        return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
    }
}
-
-String[] firstNames = ["Ferra", "Dani", "Jordi", "Joan", "Martin"]
-String[] lastNames = ["Adria", "Garcia", "Cruz", "Roca", "Berasategi"]

+User[] users = [
+   new User(firstName: "Ferra", lastName: "Adria"),
+    new User(firstName: "Dani", lastName: "Garcia"),
+    new User(firstName: "Jordi", lastName: "Cruz"),
+    new User(firstName: "Joan", lastName: "Roca"),
+    new User(firstName: "Martin", lastName: "Berasategi"),
+];
-
-for (int i = 0; i < firstNames.size(); i++) {
-   User u = new User(firstName: firstNames[i], lastName: lastNames[i]);
-   println("UserName is ${u.UserName()}")
-}
+for (int i = 0; i < users.size(); i++) {
+   println("UserName is ${users[i].UserName()}")
+}
```
