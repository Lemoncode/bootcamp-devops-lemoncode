# Herencia

* Es posible qeu no la necesiatemos
* `Groovy` soporta lass interfaces
    - Las interfaces para el scripting no suele tener mucho sentido
    - Tienen más cabida las clases abstractaas
* Las clases abstractas no tienen implementación 
* Nadie tiene _exactamente_ un coche
* Tienen _instancias_ de un coche 
* Copiar y pegar es maligno


# Demo: Herencia

Crear el siguiente fichero [05_inheritance.groovy](playground/05_inheritance.groovy)

Comenzamos desde este código:

```groovy
class User {
    String lastName;
    String firstName;

    public String UserName() {
        return getUserName(this.firstName, this.lastName);
    }

    String getUserName(String firstName, String lastName) {
        return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
    }
}

User[] users = [
    new User(firstName: "Ferra", lastName: "Adria"),
    new User(firstName: "Dani", lastName: "Garcia"),
    new User(firstName: "Jordi", lastName: "Cruz"),
    new User(firstName: "Joan", lastName: "Roca"),
    new User(firstName: "Martin", lastName: "Berasategi"),
];

users.each(user -> println("UserName is ${user.UserName()}"))

```

Y lo podemos ejecutar de la siguiente manera

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 05_inheritance.groovy 
UserName is bdylan
UserName is jlynne
UserName is rorbison
UserName is gharrison
UserName is tpetty
```

Si cambiamos el tipo de la clase a `abstract` nos da una excepción, tal y como esperabamos

```diff
-class User {
+abstract class User {
    String lastName;
    String firstName;

    public String UserName() {
        return getUserName(this.firstName, this.lastName);
    }

    private String getUserName(String firstName, String lastName) {
        return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
    }
}
```

Vamos a crear un par de clases que extiendan de `User`

```groovy
abstract class User {
    String lastName;
    String firstName;

    public String UserName() {
        return getUserName(this.firstName, this.lastName);
    }

    private String getUserName(String firstName, String lastName) {
        return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
    }
}

/*diff*/
class FirstChef extends User {
    public String[] Dishes;
}

class Baker extends User {
    public void Bake() {}
}
/*diff*/

User[] users = [
    new User(firstName: "Ferra", lastName: "Adria"),
    new User(firstName: "Dani", lastName: "Garcia"),
    new User(firstName: "Jordi", lastName: "Cruz"),
    new User(firstName: "Joan", lastName: "Roca"),
    new User(firstName: "Martin", lastName: "Berasategi"),
];

users.each(user -> println("UserName is ${user.UserName()}"))

```

Para resolver nuestro problema previo, tenemos que reemplazar `User`

```diff
User[] users = [
-   new User(firstName: "Ferra", lastName: "Adria"),
-   new User(firstName: "Dani", lastName: "Garcia"),
-   new User(firstName: "Jordi", lastName: "Cruz"),
-   new User(firstName: "Joan", lastName: "Roca"),
-   new User(firstName: "Martin", lastName: "Berasategi"),
+   new FirstChef(firstName: "Ferra", lastName: "Adria"),
+   new FirstChef(firstName: "Dani", lastName: "Garcia"),
+   new FirstChef(firstName: "Jordi", lastName: "Cruz"),
+   new FirstChef(firstName: "Joan", lastName: "Roca"),
+   new FirstChef(firstName: "Martin", lastName: "Berasategi"),
];
```

Para terminar, tomemos ventaja del `polimorfismo`, veamos el resultado final

```groovy
abstract class User {
    String lastName;
    String firstName;

    public String UserName() {
        return getUserName(this.firstName, this.lastName);
    }

    String getUserName(String firstName, String lastName) {
        return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
    }
}

class FirstChef extends User {
    public String[] Dishes;
}

class Baker extends User {
    public void Bake() {
        /*diff*/
        println("Dessert ready");
        /*diff*/
    }
}

/*diff*/
User[] users = [
    new FirstChef(firstName: "Ferra", lastName: "Adria", Dishes: ["Locura"]),
    new FirstChef(firstName: "Dani", lastName: "Garcia", Dishes: ["Mojama"]),
    new FirstChef(firstName: "Jordi", lastName: "Cruz", Dishes: ["Rocas de Mar"]),
    new Baker(firstName: "Joan", lastName: "Roca"),
    new FirstChef(firstName: "Martin", lastName: "Berasategi", Dishes: ["Torrija"]),
];
/*diff*/

/*diff*/
users.each{
    user ->
    if (user instanceof FirstChef) {
        println("Username is ${user.UserName()}");
        user.Dishes.each(d -> println("${d}"));
    } else {
        user.Bake();
    }
}
/*diff*/

```