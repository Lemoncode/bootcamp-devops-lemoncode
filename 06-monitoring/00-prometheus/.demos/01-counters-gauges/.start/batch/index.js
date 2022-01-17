const express = require('express');
const { port } = require('./config');
const { batch } = require('./batch');

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
