# Todo App React

## Environment Variables

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

## Start Database using Docker

```bash
$ docker run -d -p 5432:5432 -v todos:/var/lib/postgresql/data --name postgres postgres:10.4
```

If the database was not initialized, we can solve this by:

```bash
$ docker exec -i postgres psql -U postgres < create_todos_db.sql
```

Notice, that since we have a volume we will not need to run again the above code.

## Migrations

To create a new `knexfile.js` run: 

```bash
$ $(npm bin)/knex init 
```

### Creating a Table

```bash
$ $(npm bin)/knex migrate:make create_todos_table
Using environment: development
Using environment: development
Using environment: development
Created Migration: /Users/jaimesalaszancada/Documents/paths/ci_cd-path/04_gitlab_or/todo-app-react/migrations/20201122205735_create_todos_table.js
```

We can create the migration code as follows:

```js
exports.up = function(knex) {
    return knex.schema.createTable('todos', function(table) {
        table.increments('id');
        table.string('title', 255).notNullable();
        table.boolean('completed').notNullable();
    });
};

exports.down = function(knex) {
    return knex.schema.dropTable('users');
};
```

To see pending migrations

```bash
$ $(npm bin)/knex migrate:list
Using environment: development
No Completed Migration files Found. 
Found 1 Pending Migration file/files.
20201122205735_create_todos_table.js
```

To run the migration

```bash
$ $(npm bin)/knex migrate:up 20201122205735_create_todos_table.js
Using environment: development
Batch 1 ran the following migrations:
20201122205735_create_todos_table.js
```

### Updating table

* The previous table must be updated with two new columns:
    - due_date -> `datetime`
    - order -> `int`

As before we create the migration

```bash
$ $(npm bin)/knex migrate:make update_todos_table
Using environment: development
Using environment: development
Using environment: development
Created Migration: /Users/jaimesalaszancada/Documents/paths/ci_cd-path/04_gitlab_or/todo-app-react/migrations/20201123104711_update_todos_table.js
```

And the migration will look as follows:

```js
exports.up = function(knex) {
  return knex.schema.table('todos', (t) => {
      t.datetime('due_date');
      t.integer('order');
  });
};

exports.down = function(knex) {
    return knex.schema.table('todos', (t) => {
        t.dropColumn('due_date');
        t.dropColumn('order');
    });
};
```

To apply all pending migrations, we can run:

```bash
$ $(npm bin)/knex migrate:list
Using environment: development
No Completed Migration files Found. 
Found 2 Pending Migration file/files.
20201122205735_create_todos_table.js 
20201123104711_update_todos_table.js 

$ $(npm bin)/knex migrate:latest
Using environment: development
Batch 1 run: 2 migrations
```

### Seeding the database with Knex

Update `knexfile.js` as follows

```diff
# .....
development: {
    client: 'pg',
    connection: {
      host: process.env.DB_HOST || 'localhost',
      database: process.env.DB_NAME || 'todos',
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD || 'postgres',
      dbVersion: process.env.DB_VERSION || '10.4',
      port: +process.env.DB_PORT || 5432,
    },
    pool: {
      min: 2,
      max: 10,
    },
    migrations: {
      tableName: 'migrations',
    },
+   seeds: {
+     directory: './data/seeds',
+   }
  },
# .....
```

Now to generate the seed file we must run `$(npm bin)/knex seed:make todos`

```bash
$ $(npm bin)/knex seed:make todos
Using environment: development
Using environment: development
Using environment: development
Created seed file: /Users/jaimesalaszancada/Documents/paths/ci_cd-path/04_gitlab_or/todo-app-react/data/seeds/todos.js
```

```js
exports.seed = function(knex) {
  // Deletes ALL existing entries
  return knex('todos').truncate()
    .then(function () {
      // Inserts seed entries
      return knex('todos').insert([
        { title: 'Learn GitHub Actions', completed: false },
        { title: 'Learn Groovy', completed: false },
        { title: 'Learn EKS', completed: false },
      ]);
    });
};

```

To run the seed now we can do

```bash
$ $(npm bin)/knex seed:run
```

#### Migration References

> Quick Start Tutorial: http://perkframework.com/v1/guides/database-migrations-knex.html
> Seeding a database with Knex: https://dev.to/cesareferrari/database-seeding-with-knex-51gf

## Running the Application with Docker on Local

```bash
$ docker build -t jaimesalas/lc-todo-monolith . 
```

Create network

```bash
$ docker create network lemoncode
```

Start database

```bash
docker run -d --network lemoncode -v todos:/var/lib/postgresql/data --name postgres postgres:10.4
```

Start app without database

```bash
$ docker run -d -p 3000:3000 \
  -e NODE_ENV=production \
  -e PORT=3000 \
  jaimesalas/lc-todo-monolith
```

Start up with database 

```bash
$ docker run -d --network lemoncode -p 3000:3000 \
  -e NODE_ENV=production \
  -e PORT=3000 \
  -e DB_HOST=postgres \
  -e DB_USER=postgres \
  -e DB_PASSWORD=postgres \
  -e DB_PORT=5432 \
  -e DB_NAME=todos_db \
  -e DB_VERSION=10.4 \
  --name monolith \
  jaimesalas/lc-todo-monolith
```

## Create stand alone database

```bash
$ docker build -t jaimesalas/lc-todo-db -f Dockerfile.todos_db .
```

```bash
$ docker run -d -p 5432:5432 -v other_todos:/var/lib/postgresql/data --name lc-todo-db jaimesalas/lc-todo-db
```