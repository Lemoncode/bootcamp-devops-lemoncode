# Start Code Solution

## Environment variables

```ini
# DATA_BASE
DATA_BASE_ACTIVE=false
DATABASE_PORT=5432
DATABASE_HOST=localhost
DATABASE_NAME=hangman_db
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres
DATABASE_POOL_MIN=2
DATABASE_POOL_MAX=10
# HTTP_SERVER
PORT=3000
HOST=0.0.0.0
```

## Start Up Database Locally

Run database as Docker container:

```bash
docker run -d \
    -p 5432:5432 \
    --name "hangman_db" \
    -e "POSTGRES_USER=postgres" \
    -e "POSTGRES_PASSWORD=postgres" \
    -e "POSTGRES_DB=hangman_db" \
    postgres:14-alpine
```

This command creates a new postgres server whose default database is `hangman_db`. Once the database is running, we can check its content by running:

```bash
docker exec -it hangman_db psql -U postgres
```


## Datbase set up

* From `hangman-api` directory

```bash
npx knex init
```

* To interact with migrations we need that the database is running.

```bash
npx knex migrate:make create_tables 
```

Now we can add the desired code to our migrations, check the different options [here](https://knexjs.org/guide/schema-builder.html). Once this is done, we can run the migrations to set up the database tables as we want:

```bash
DATA_BASE_ACTIVE=false \
DATABASE_PORT=5432 \
DATABASE_HOST=localhost \
DATABASE_NAME=hangman_db \
DATABASE_USER=postgres \
DATABASE_PASSWORD=postgres \
DATABASE_POOL_MIN=2 \
DATABASE_POOL_MAX=10 \
npx knex migrate:latest --env development
```

Now we can create a seed for our tests if we want by running:

```bash
knex seed:make seed_name
```

## Running integration tests

### Locally

* Using `.env.test`

```bash
npm run test:integration 
```

* Using defined env variables

```bash
DATA_BASE_ACTIVE=false \
DATABASE_PORT=5432 \
DATABASE_HOST=localhost \
DATABASE_NAME=hangman_db \
DATABASE_USER=postgres \
DATABASE_PASSWORD=postgres \
DATABASE_POOL_MIN=2 \
DATABASE_POOL_MAX=10 \
npm run test:integration
```

## Running API and Front as containers

```bash
cd hangman-api 
docker build -t jaimesalas/hangman-api .
```

```bash
cd hangman-front 
docker build -t jaimesalas/hangman-front .
```

```bash
docker run -d -p 3001:3000 jaimesalas/hangman-api
```

```bash
docker run -d -p 8081:8080 -e API_URL=http://localhost:3001 jaimesalas/hangman-front
```

## Running e2e

```bash
docker run -d -p 3001:3000 jaimesalas/hangman-api
docker run -d -p 8080:8080 -e API_URL=http://localhost:3001 jaimesalas/hangman-front
```

```bash
cd hangman-e2e/e2e
npm run open
```
