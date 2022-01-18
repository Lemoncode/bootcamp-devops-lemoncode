# Nodejs Client Library

Los ejemplos que vamos a ver los vamos a realizar en Nodejs, el proceso para cualquier otro lenguaje sería el mismo o muy similar a lo que se expone aquí.

El ejemplo que vamos a crear se trata de un `batch process` ficticio que irá variando a lo largo del tiempo. El punto de partida en código lo podemos encontrar en `02-gauges-counters/.start/batch` y el resultado final en `.solutions/batch`

## Pasos

## 1. Instalamos el cliente de Prometheus

En el caso de Nodejs el cliente de Prometheus es [prom-client](https://github.com/siimon/prom-client)

```bash
 npm i prom-client
```

## 2. Creamos nuestras custom metrics

```js
// Reference: https://github.com/siimon/prom-client/blob/master/example/counter.js
const counter = new promClient.Counter({
  name: 'worker_jobs_total',
  help: 'Total jobs handle',
  labelNames: ['code']
});

// Reference: https://github.com/siimon/prom-client/blob/master/example/gauge.js
const gauge = new promClient.Gauge({
  name: 'worker_jobs_active',
  help: 'Worker jobs in process'
});


module.exports.counter = counter;
module.exports.gauge = gauge;
```

## 3. Actualizamos la 'lógica' de procesos

Actualizar `batch.js`

```js
/*diff*/
const { counter, gauge } = require('./custom-metrics');
/*diff*/

const getRandom = (start, end) => Math.floor((Math.random() * end) + start);

const randomBatchProcess = () => {
  const jobs = getRandom(50, 500);
  const failed = getRandom(1, 50);
  const processed = jobs - failed;
  const active = getRandom(1, 100);
  return { active, failed, processed };
};

module.exports.batch = () => {
  const intervalId = setInterval(() => {
    const { active, failed, processed } = randomBatchProcess();
    /*diff*/
    counter.labels('200').inc(processed);
    counter.labels('500').inc(failed);

    gauge.set(active);
    /*diff*/
  }, 5_000);

  return intervalId;
};
```

## 4. Recuperamos las métricas

Lo primero que vamos a hacer es recuperar las métricas que expone por defecto `prom-client`

Actualizamos `index.js`

```diff
const express = require('express');
+const promClient = require('prom-client');
const { port } = require('./config');
const { batch } = require('./batch');
+
+const { register, collectDefaultMetrics } = promClient;
+
+collectDefaultMetrics({ prefix: 'default_' });
const intervalId = batch();
const app = express();

app.get('/metrics', async (_, res) => {
  try {
    res.send('Not implemented yet');
  } catch (ex) {
    res.status(500).end(ex);
  }
});

app.post('/stop', (_, res) => {
  clearInterval(intervalId);
  res.send('batch process stopped');
});

app.listen(port, () => {
  console.log(`Listening at ${port}`);
});

```

Por último tenemos que indicar a `prom-client`, cuando debemos volcar las métricas:

```diff
app.get('/metrics', async (_, res) => {
  try {
-   res.send('Not implemented yet');
+   res.set('Content-Type', register.contentType);
+   res.end(await register.metrics());
  } catch (ex) {
    res.status(500).end(ex);
  }
});
```

Si ejecutamos nuestra aplicación ahora podremos ver como las métricas son expuestas en el formato `Prometheus`

```bash
npm start
```

Y desde otra terminal, podemos verificar la salida con `curl localhost:3000/metrics`


```ini
# HELP worker_jobs_total Total jobs handle
# TYPE worker_jobs_total counter
worker_jobs_total{code="200"} 739
worker_jobs_total{code="500"} 44

# HELP worker_jobs_active Worker jobs in process
# TYPE worker_jobs_active gauge
worker_jobs_active 52

# HELP default_process_cpu_user_seconds_total Total user CPU time spent in seconds.
# TYPE default_process_cpu_user_seconds_total counter
default_process_cpu_user_seconds_total 0.185732

# HELP default_process_cpu_system_seconds_total Total system CPU time spent in seconds.
# TYPE default_process_cpu_system_seconds_total counter
default_process_cpu_system_seconds_total 0.027831

# HELP default_process_cpu_seconds_total Total user and system CPU time spent in seconds.
# TYPE default_process_cpu_seconds_total counter
default_process_cpu_seconds_total 0.213563

#........ 
```