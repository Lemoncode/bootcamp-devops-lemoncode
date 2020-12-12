# Todo App

## Run solution locally

Start up a database with database ready to work locally, we run the following command

```bash
$ docker run --rm -d -p 5432:5432 --name postgres postgres:10.4
```

Once the container is running we can populate the data by

```bash
$ docker exec -it postgres psql -U postgres
```

Paste the code `todo-app/todos_db.sql` and the database must be started with some data.

### Environment Variables

Create `todo-app/.env` with the previous database configuration thes values must be

```ini
NODE_ENV=develop
PORT=3000
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=postgres
DB_PORT=5432
DB_NAME=todos_db
DB_VERSION=10.4
```

### Running Applications

First we need to install dependencies change directory to `todo-app/frontend` and run `npm install`, then change directory to `/todo-app` and run `npm install`. Once that all dependencies are installed, we can run the solution locally by changing directory to `todo-app/frontend` and running `npm run run-p -l start:server start:dev`.