# Añadiendo Summaries e Histogramas

En esta demo vamos arrancar con la libreía de `prom-client` ya instalada.

El ejemplo que vamos a crear se trata de una aplicación web que expone un endpoint al cual podremos llamar y nos devolverá una 'cita'.

## Pasos

## 1. Creamos las métricas

Creamos `custom-metrics.js`

```js
const promClient = require('prom-client');

const counter = new promClient.Counter({
  name: 'http_requests_received_total',
  help: 'Total number of requests received and response code',
  labelNames: ['method', 'response_code']
});


const histogram = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Shows processing requests durations',
  labelNames: ['code']
});

const delaySummary = new promClient.Summary({
  name: 'web_delay_seconds',
  help: 'Custom delay added',
});

module.exports.counter = counter;
module.exports.histogram = histogram;
module.exports.delaySummary = delaySummary;
```

## 2. Actualizamos index.js

Abrimos el fichero `index.js`

Primero vamos añadir las métricas que se exponen por defecto:

```diff
const express = require('express');
+const promClient = require('prom-client');
const { port } = require('./config');
const { getQuote } = require('./helpers');

+const { register, collectDefaultMetrics } = promClient;
+
+collectDefaultMetrics();

const app = express();

// curl -X GET "http://localhost:3000/quote"
app.get('/quote', async (_, res) => {
  try {
    const quote = getQuote();
    res.send(quote);
  } catch (ex) {
    res.status(500).end(ex);
  }
});

app.listen(port, () => {
  console.log(`Listenning at ${port}`);
});
```

Vamos a hacer que el endpoint se comporte de una manera distinta en función de recibir un `query param`. Además queremos resgistrar cada vez que se realiza una petición al endpoint `quote`

```diff
const express = require('express');
const promClient = require('prom-client');
const { port } = require('./config');
-const { getQuote } = require('./helpers');
+const { getQuote, delay, getRandom } = require('./helpers');
+const { counter, histogram, delaySummary } = require('./custom-metrics');
# ....
```

Y actualizamos el endpoint de la siguiente manera.

```js
// curl -X GET "http://localhost:3000/quote?slow=true"
app.get('/quote', async (req, res) => {
  try {
    counter.labels('GET', 200).inc();
    const end = histogram.startTimer();
    const quote = getQuote();
    const { slow } = req.query;

    if (slow === 'true') {
      const delaySeconds = getRandom(2, 10);
      delaySummary.observe(delaySeconds);
      await delay(delaySeconds);
    }

    histogram.labels(200).observe(end());
    res.send(quote);
  } catch (ex) {
    counter.labels('GET', 500).inc();
    res.status(500).end(ex);
  }
});
```

Para que esto funcione debemos exponer las métricas.

```js
// curl http://localhost:3000/metrics
app.get('/metrics', async (_, res) => {
  try {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (ex) {
    res.status(500).end(ex);
  }
});
```

## 3. Comprobamos la app

Vamos a comprobar que la aplicación funciona como nosotros esperamos

```bash
npm start
```

En un terminal nuevo hagamos un par de peticiones:

```bash
curl -X GET "http://localhost:3000/quote?slow=true"
curl -X GET "http://localhost:3000/quote"
```

Y podemos obtener las métricas llamando a su endpoint:

```bash
curl http://localhost:3000/metrics
```

```ini
# HELP http_requests_received_total Total number of requests received and response code
# TYPE http_requests_received_total counter
http_requests_received_total{method="GET",response_code="200"} 2

# HELP http_request_duration_seconds Shows processing requests durations
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{le="0.005"} 0
http_request_duration_seconds_bucket{le="0.01"} 0
http_request_duration_seconds_bucket{le="0.025"} 0
# ....
```