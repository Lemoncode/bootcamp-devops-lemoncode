# Todo Front

## Build to Test on local

```bash
$ docker build -t lemoncode/todo-front --build-arg  API_HOST=http://localhost:3000 .
```

## Running on local

```bash
$ docker run -d -p 80:80 lemoncode/todo-front
```