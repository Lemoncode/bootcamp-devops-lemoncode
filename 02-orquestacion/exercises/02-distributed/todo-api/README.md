# Todo App React

## Environment Variables

```ini
NODE_ENV=
PORT=
```

## Running the Application with Docker on Local

```bash
$ docker build -t lemoncode/todo-api . 
```

Start app without database

```bash
$ docker run -d -p 3000:3000 \
  -e NODE_ENV=production \
  -e PORT=3000 \
  lemoncode/todo-api
```
