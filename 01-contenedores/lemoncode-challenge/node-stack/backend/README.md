# backend

## Running Locally

This application has a direct dependency with mongo. To running locally by default the application expects that mongo is listening on port 27017.

It's going to connect with `TopicstoreDb` on mongo server, and it's foing to interact with `Topics` collection.

It's important to mention, that the default connection string is `mongodb://localhost:27017`, we can override it, using env variables.

The following are environment variables that we can set up:

```ini
DATABASE_URL=
DATABASE_NAME=
HOST=
PORT=
```

Notice that `HOST` is set by default on `localhost` and `PORT` on `5000`. These are the settings to stablish where the HTTP application is listening. You don't need to change it.

With the database running on local, you can check the appliaction by running:

> NOTE: If is the first time that you run it, no data will be available

```bash
npm start
```

And then call it with:

```bash
curl http://localhost:5000/api/topics
```

If you want to feed some data you can try:

```bash
curl -d '{"Name":"Devops"}' -H "Content-Type: application/json" -X POST http://localhost:5000/api/topics
curl -d '{"Name":"K8s"}' -H "Content-Type: application/json" -X POST http://localhost:5000/api/topics
curl -d '{"Name":"Docker"}' -H "Content-Type: application/json" -X POST http://localhost:5000/api/topics
curl -d '{"Name":"Prometheus"}' -H "Content-Type: application/json" -X POST http://localhost:5000/api/topics
```
