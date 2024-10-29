# Profiles Compose

Profiles help you adjust your Compose application for different environments or use cases by selectively activating services. Services can be assigned to one or more profiles; unassigned services start by default, while assigned ones only start when their profile is active.

The services are associated with profiles, for example:

Create `my-app/docker-compose.profiles.yml`

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
  
  mongodb:
    image: mongo:latest
```

The services `frontend` and `backend` are assigned to the profiles `frontend` and `debug` respectively and as such are only started when their respective profiles are enabled.

> Services without a `profiles` attribute are always enabled.

```bash
docker compose -f docker-compose.profiles.yml up 
```

Only `mongodb` starts up.

```bash
docker compose -f docker-compose.profiles.yml down 
```

Start a specific profile

```bash
docker compose -f docker-compose.profiles.yml --profile frontend up 
```

Now `mongodb` and `frontend` are started. We can stop a specific profile:

```bash
docker compose -f docker-compose.profiles.yml --profile frontend down 
```


We can start multiple profiles

```bash
docker compose -f docker-compose.profiles.yml --profile frontend --profile debug up 
```

We can shut down:

```bash
docker compose -f docker-compose.profiles.yml --profile frontend --profile debug down
```