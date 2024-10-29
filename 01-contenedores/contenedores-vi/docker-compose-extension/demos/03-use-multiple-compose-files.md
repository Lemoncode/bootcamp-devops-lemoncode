# Use Multiple Compose files

Using multiple Compose files lets you customize a Compose application for different environments or workflows. This is useful for large applications that may use dozens of containers, with ownership distributed across multiple teams. For example, if your organization or team uses a monorepo, each team may have their own “local” Compose file to run a subset of the application. They then need to rely on other teams to provide a reference Compose file that defines the expected way to run their own subset. Complexity moves from the code in to the infrastructure and the configuration file.

The quickest [merge](https://docs.docker.com/compose/how-tos/multiple-compose-files/merge/). However, [merging rules](https://docs.docker.com/compose/how-tos/multiple-compose-files/merge/#merging-rules) means this can soon get quite complicated.

Create `compose.yml`

```yml
services:
  web:
    image: nginx
    depends_on:
      - db
      - cache
  
  db:
    image: postgres:latest

  cache:
    image: redis:latest
```

Create `compose.override.yml`

```yml
services:
  web:
    volumes:
      - 'code:/tmp'
    ports:
      - 8900:80
    environment:
      DEBUG: 'true'

  db:
    ports:
      - 5432:5432
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_USER: admin

  cache:
    ports:
      - 6379:6379

volumes:
  code:

```

```bash
docker compose up
```

Now reads by dedfault `compose.override` and applies the updates. Let's say that we want to run in another environment:

Create `compose.staging.yml`

```yml
services:
  web:
    ports:
      - 80:80
    environment:
      PRODUCTION: 'true'

  db:
    environment:
      POSTGRES_HOST_AUTH_METHOD: trust
  
  cache:
    environment:
      TTL: '500'
```

```bash
docker compose -f compose.yml -f compose.staging.yml up
```
