const express = require('express');
const promClient = require('prom-client');
const { port } = require('./config');
const { batch } = require('./batch');

const { register, collectDefaultMetrics } = promClient;

collectDefaultMetrics({ prefix: 'default_' });
const intervalId = batch();
const app = express();

app.get('/metrics', async (_, res) => {
  try {
    // res.send('Not implemented yet');
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
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
