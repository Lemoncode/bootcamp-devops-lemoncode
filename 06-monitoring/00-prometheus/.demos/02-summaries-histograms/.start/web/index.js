const express = require('express');
const { port } = require('./config');
const { getQuote } = require('./helpers');

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