const express = require('express');
const promClient = require('prom-client');
const { port } = require('./config');
const { getQuote, delay, getRandom } = require('./helpers');
const { counter, histogram, delaySummary } = require('./custom-metrics');

const { register, collectDefaultMetrics } = promClient;

collectDefaultMetrics();

const app = express();

// curl http://localhost:3000/metrics
app.get('/metrics', async (_, res) => {
  try {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (ex) {
    res.status(500).end(ex);
  }
});


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

app.listen(port, () => {
  console.log(`Listenning at ${port}`);
});