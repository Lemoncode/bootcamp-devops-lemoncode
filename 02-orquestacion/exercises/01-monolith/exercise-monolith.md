# Monolito

## Enunciado

Construir los distintos recursos de Kubernetes para generar un clúster, como el de la siguiente imagen:

![monolith in memory](./monolith.png)

### Para ello seguir los siguientes pasos:

### Paso 1. Crear una capa de persistencia de datos

Crear un `StatefulSet` para tener una base de datos dentro del cluster, para ello generar los siguientes recursos: 

* Crear un `ConfigMap` con la configuración necesaria de base de datos
* Crear un `StorageClass` para el aprovisionamineto dinámico de los recursos de persistencia
* Crear un `PersistentVolume` que referencie el `StorageClass` anterior
* Crear un `PersistentVolumeClaim` que referencie el `StorageClass` anterior
* Crear un `Cluster IP service`, de esta manera los pods del `Deployment` anterior serán capaces de llegar al `StatefulSet`
* Crear el `StatefulSet` alimentando las variables de entorno y el volumen haciendo referencia al `PersistentVolumeClaim` creado anteriormente.

> **Nota**: Para la BBDD podéis usar la imagen `lemoncodersbc/lc-todo-monolith-psql:v5-2024`. ¿Qué tiene esa imagen? Se trata de una imagen que hereda de `postgres` pero añade el fichero `todos_db.sql` como script de inicio (ver fichero `./todo-app/Dockerfile.todos_db`)

Una vez tengamos nuestro `StatefulSet` corriendo la manera más directa de generar la base de datos sería (seed de datos):

* Ejecutamos `kubectl get pods`, y obtenemos el nombre del pod relacionado con el `StatefulSet`.
* Ejecutamos `kubectl exec [postgres-pod-name] -it bash`
* Ejecutamos `psql -U postgres`, pegamos `todo-app/todos_db.sql` y pulsamos `enter`, la base de datos debería estar generada

> **Nota**: Estos pass no deberían ser necesarios si habeís usado la imagen `lemoncodersbc/lc-todo-monolith-psql:v5-2024` en el StatefulSet

### Paso 2. Crear todo-app

Crear un `Deployment` para `todo-app`, usar el `Dockerfile` de este direetorio **todo-app**, para generar la imagen necesaria.

> Nota: Podéis usar la imagen `lemoncodersbc/lc-todo-monolith-db:v5-2024`

Al ejecutar un contenedor a partir de la imagen anaterior, el puerto por defecto es el 3000, pero se lo podemos alimentar a partir de  variables de entorono, las variables de entorno serían las siguientes

* **NODE_ENV** : El entorno en que se está ejecutando el contenedor, nos vale cualquier valor que no sea `test`
* **PORT** : El puerto por el que va a escuchar el contenedor
* **DB_HOST** : El host donde se encuentra la base de datos
* **DB_USER**: El usuario que accede a la base de datos, podemos usar el de por defecto `postgres`
* **DB_PASSWORD**: El password para acceeder a la base de datos, podemos usar el de por defecto `postgres`
* **DB_PORT** : El puerto en el que postgres escucha `5432`
* **DB_NAME** : El nombre de la base de datos, en `todo-app/todos_db.sql`, el script de inicialización recibe el nombre de `todos_db`
* **DB_VERSION** : La versión de postgres a usar, en este caso `10.4`

Crear un `ConfigMap` con todas las variables de entorno, que necesitarán los pods de este `Deployment`.

> NOTA: Las obligatorias son las de la base de datos, todas aquellas que comienzan por `DB`

### Paso 3. Acceder a todo-app desde fuera del clúster

Crear un `LoadBalancer service` para acceder al `Deployment` anteriormente creado desde fuera del clúster. Para poder utilizar un `LoadBalancer` con minikube seguir las instrucciones de este [artículo](https://minikube.sigs.k8s.io/docs/handbook/accessing/)

## Comentarios

Hacer un _seed_ de datos de una BBDD es una tarea muchas veces necesarias. Usar una imagen "cocinada" no es, ni de lejos, la mejor de las opciones ya que **implica generar la imagen cada vez que el sql del seed se modifica** lo que no es muy correcto.

En su lugar, hay varias alternativas que podríamos usar:

1. En lugar de usar una imagen "cocinada" que es idéntica a la original pero con un fichero añadido podríamos pasar este fichero a través de un volumen (poner el fichero en un ConfigMap y montar el ConfigMap en el contenedor).
2. Usar un job de Kubernetes que ejecutase el script. Este job podría ejecutar un contenedor que usase el cliente de la bbdd (psql en nuestro caso) y que lanzase el script contra la bbdd. El script se lo pasaríamos mediante un volumen usando un ConfigMap.
3. Usar un _init container_ en el cliente (**no en la base de datos**). No podemos usar un _init container_ en el pod de la bbdd porque cuando se ejecutaría este _init container_ no se estaría ejecutando la bbdd. No obstante usar un _init container_ en el cliente (el pod de la app) no es una buena idea por dos motivos: el primero es que si el cliente se levanta antes que la bbdd,  el _init container_ no se podrá ejecutar, dará error y el pod quedará en `Init:Error`. El segundo es que este _init container_ se ejecutaría cada vez que se crease el pod de la app (si se escala horizontalmente cada pod tendrá su propio _init container_), por  lo que el script debe estar preparado para poder ser ejecutado N veces en paralelo y ser idempotente (lo que añade una complejidad inecesaria).