# backend

## Ejecutar Localmente

Esta aplicación tiene una dependencia directa con MongoDB. Para ejecutarla localmente, por defecto *la aplicación espera que MongoDB esté escuchando en el puerto 27017*.

Se conectará con `TopicstoreDb` en el servidor MongoDB e interactuará con la colección `Topics`.

Es importante mencionar que la cadena de conexión predeterminada es `mongodb://localhost:27017`, pero podemos sobrescribirla usando variables de entorno.

Las siguientes son las variables de entorno que podemos configurar:

```ini
DATABASE_URL=
DATABASE_NAME=
HOST=
PORT=
```

Ten en cuenta que `HOST` está establecido por defecto en `localhost` y `PORT` en `5000`. Estos son los parámetros que establecen dónde está escuchando la aplicación HTTP. No necesitas cambiarlos.

Con la base de datos ejecutándose localmente, puedes comprobar la aplicación ejecutando:

> NOTA: Si es la primera vez que la ejecutas, no habrá datos disponibles


Instala las dependencias:

```bash
npm install
```

Luego inicia la aplicación con:

```bash
npm start
```

Y luego llamarla con:

```bash
curl http://localhost:5000/api/topics
```

Si quieres cargar algunos datos puedes intentar:

```bash
curl -d '{"Name":"Devops"}' -H "Content-Type: application/json" -X POST http://localhost:5000/api/topics
curl -d '{"Name":"K8s"}' -H "Content-Type: application/json" -X POST http://localhost:5000/api/topics
curl -d '{"Name":"Docker"}' -H "Content-Type: application/json" -X POST http://localhost:5000/api/topics
curl -d '{"Name":"Prometheus"}' -H "Content-Type: application/json" -X POST http://localhost:5000/api/topics
```
