# Todo App React

## Run solution locally

First we need to install dependencies change directory to `todo-app/frontend` and run `npm install`, then change directory to `/todo-app` and run `npm install`. Once that all dependencies are installed, we can run the solution locally by changing directory to `todo-app/frontend` and running `npm run start:dev:server`.

```bash
# 1. Install frontend dependencies
cd ./todo-app/frontend
npm install

# 2. Install backend dependencies
cd ../
mpm install

# 3. To start solution run the following command
npm run start:dev:server
```

## Environment Variables

```ini
NODE_ENV=
PORT=
```

## Running the Application with Docker on Local

```bash
$ docker build -t jaimesalas/lc-todo-monolith . 
```

Start app without database

```bash
$ docker run -d -p 3000:3000 \
  -e NODE_ENV=production \
  -e PORT=3000 \
  jaimesalas/lc-todo-monolith
```
