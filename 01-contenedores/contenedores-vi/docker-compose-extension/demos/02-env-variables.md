# Using environment variables

Update `my-app/backend/index.js`

```diff
router.get("/topics", async (_, res) => {
  console.log("[GET] Topics");
  console.log(Topic);

  try {
    const collection = await Topic.find({});
    const topics = collection.map((t) => ({
      id: t._id.toString(),
      name: t.name,
    }));
    res.send(topics);
  } catch (error) {
    console.error(err);
    res.send(JSON.parse(error));
  }
});
+
+router.get("/setup", async (_, res) => {
+ const debug = process.env.DEBUG ?? "no value";
+ res.send({ debug });
+});
+
//all routes will be prefixed with /api
app.use("/api", router);

```

Create `docker-compose.envs.yml`

```yml
services:
  frontend:
    build:
      context: ./frontend
    deploy:
      replicas: 1
    ports:
      - 3000:8080
    profiles: [frontend]

  backend:
    build:
      context: ./backend
    ports:
      - 8080:8080
    depends_on:
      - mongodb
    profiles: [debug]
    # diff #
    environment:
      - DEBUG="my hard coded value"
    # diff #

  mongodb:
    image: mongo:latest
```

```bash
docker compose -f docker-compose.envs.yml --profile debug up --build
```

```bash
curl http://localhost:8080/api/setup
```

Instead of using hard coded values, we can use variables declare in shell. Let's try it:

```bash
docker compose -f docker-compose.envs.yml --profile debug down
```

Update `my-app/docker-compose.envs.yml`

```diff
  backend:
    build:
      context: ./backend
    ports:
      - 8080:8080
    depends_on:
      - mongodb
    profiles: [debug]
    environment:
-     - DEBUG="my hard coded value"
+     - DEBUG
```

```bash
export DEBUG="from shell"
```

```bash
docker compose -f docker-compose.envs.yml --profile debug up
```

```bash
curl http://localhost:8080/api/setup
```

```bash
docker compose -f docker-compose.envs.yml --profile debug down
```

We can also use a `.env` file, `docker compose` will look for this file in order to set up the ennvironment variables.

```bash
unset DEBUG
```

Create `my-app/.env`

```ini
DEBUG="from .env file"
```

```bash
docker compose -f docker-compose.envs.yml --profile debug up
```

```bash
curl http://localhost:8080/api/setup
```

What happens when the environment variables is not set? Let's remove the `.env` file, and see what happens.

```bash
docker compose -f docker-compose.envs.yml --profile debug down
```

```bash
rm my-app/.env
```

```bash
docker compose -f docker-compose.envs.yml --profile debug up
```

```bash
curl http://localhost:8080/api/setup
```

> No value is provided

```bash
docker compose -f docker-compose.envs.yml --profile debug down
```

It would be nice if docker compose notice us, that the environment variable is not set up, that is where [interpolation](https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/#interpolation-syntax) comes in place.

Update `my-app/docker-compose.envs.yml`

```diff
....
  backend:
    build:
      context: ./backend
    ports:
      - 8080:8080
    depends_on:
      - mongodb
    profiles: [debug]
    environment:
-     - DEBUG
+     - DEBUG=${DEBUG}
....
```

```bash
docker compose -f docker-compose.envs.yml --profile debug up
```

```bash
docker compose -f docker-compose.envs.yml --profile debug down
```

For last we can also use `env_file` attribute. The [env_file attribute](https://docs.docker.com/reference/compose-file/services/#env_file) lest use multiple `.env` files.

Update `my-app/docker-compose.envs.yml`

```diff
  backend:
    build:
      context: ./backend
    ports:
      - 8080:8080
    depends_on:
      - mongodb
    profiles: [debug]
-   environment:
-     - DEBUG=${DEBUG}
+   env_file:
+     - path: ./default.env
+       required: true
+     - path: ./override.env
+       required: false
```

Create `my-app/default.env`

```ini
DEBUG="value from default.env"
```

```bash
docker compose -f docker-compose.envs.yml --profile debug up
```

```bash
curl http://localhost:8080/api/setup
```

```bash
docker compose -f docker-compose.envs.yml --profile debug down
```

Create `my-app/override.env`

```ini
DEBUG="value from override.env"
```

```bash
docker compose -f docker-compose.envs.yml --profile debug up
```

```bash
curl http://localhost:8080/api/setup
```

```bash
docker compose -f docker-compose.envs.yml --profile debug down
```