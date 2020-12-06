# Distributed Infrastructure

## Run solutions loacally

Open two terminals, in one of them change directory to `todo-api`, and run `npm start`, in the other terminal change directory to `todo-front`, and run `npm start`

## Run solutions locally using Docker

Start backend

```bash
$ docker run -d -p 3000:3000 \
  -e NODE_ENV=production \
  -e PORT=3000 \
  --name todo-api \
  lemoncode/todo-api
```

Start frontend, in order to get connected fron and back, you must build the image as follows `docker build -t lemoncode/todo-front --build-arg  API_HOST=http://localhost:3000 .`

```bash
$ docker run -d -p 80:80 --name todo-front lemoncode/todo-front
```