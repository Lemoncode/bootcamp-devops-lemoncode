# Todo App API

## Variables de Entorno

```ini
NODE_ENV=
PORT=
DB_HOST=
DB_USER=
DB_PASSWORD=
DB_PORT=
DB_NAME=
DB_VERSION=
```

* **NODE_ENV** El entorno en el que nosencontramos
* **PORT** El puerto donde va a correr la aplicación
* **DB_HOST** El `host` donde se rncuentra corriendo la base de datos
* **DB_USER** El usuario con el cual accedemos a esa base de datos
* **DB_PASSWORD** El password asociado a ese usuario
* **DB_PORT** El puerto en el cual escucha la base de datos
* **DB_NAME** El nombre asociado a la base de datos
* **DB_VERSION** La versión del motor de la base de datos

## Arrancar la Base de Datos usando Docker

Construimos primero la imagen del servidor de la base de datos

```bash
$ docker build -t lemoncode/postgres_todo_server -f Dockerfile.todos_db .
```

Levantamos la base de datos construida anteriormente.

```bash
$ docker run -d -p 5432:5432 -v todos:/var/lib/postgresql/data --name postgres_todo_server lemoncode/postgres_todo_server
```

> NOTA: Para que la base de datos este, el volumen al que estamos mapeando debe de estar vacío, si no la inicialización no ocurrirá.

Para comprobar que la base de datos se encuentra en ejecución debemos ejecutar

```bash
$ docker exec -it postgres_todo_server psql -U postgres
```

Y dentro del listado de la bases de datos, deberíamos ver `todos_db`, para listar las bases de datos `\l`, y después `enter`.

```
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 todos_db  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)
```

Para conectar con la base de datos en nuestro entorno local, debemos tener creado un fichero `.env` en el raíz, que se vea de la siguiente manera:

```ini
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=postgres
DB_PORT=5432
DB_NAME=todos_db
DB_VERSION=10.4
```

Para generar las distintas tablas dentro de nuestra base de datos ejecutaremos:

```bash
$ $(npm bin)/knex migrate:latest
```

Para tener una semilla de datos, podemos lanzar

```bash
$ $(npm bin)/knex seed:run
```

## Ejecutando Unit Tests

Para ejecutar los unit tests, simplemente, tenemos que lanzar el siguiente comando

```bash
$ npm run test
```

## Ejecutando Tests de Integración

Para jecutar los test de integración necesitamos que la base de datos, corriendo y lista para recibir peticiones:

```bash
$ docker run -d -p 5432:5432 -v todos:/var/lib/postgresql/data --name postgres_todo_server lemoncode/postgres_todo_server
```

Después de hacer esto simplemente tenemos que ejecutar:

```bash
$ npm run test:e2e
```

## Ejecutando la aplicación con Docker en nuestro entorno local

```bash
$ docker build -t lemoncode/todo-app .
```

```bash
$ docker network create lemoncode
```

```bash
$ docker run -d -v todos:/var/lib/postgresql/data \
 --network lemoncode \
 --name pg-todo-server \
 lemoncode/postgres_todo_server
```

```bash
$ docker run -d --rm -p 3000:3000 \
  --network lemoncode \
  -e NODE_ENV=production \
  -e PORT=3000 \
  -e DB_HOST=pg-todo-server \
  -e DB_USER=postgres \
  -e DB_PASSWORD=postgres \
  -e DB_PORT=5432 \
  -e DB_NAME=todos_db \
  -e DB_VERSION=10.4 \
  lemoncode/todo-app
```

```bash
$ curl localhost:3000/api/
[{"id":1,"title":"Learn GitHub Actions","completed":false,"order":null,"dueDate":null},{"id":2,"title":"Learn Groovy","completed":false,"order":null,"dueDate":null},{"id":3,"title":"Learn EKS","completed":false,"order":null,"dueDate":null}]
```



