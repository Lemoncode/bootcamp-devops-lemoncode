const express = require('express');

const PORT = 8080;

const app = express();

app.get('/', (req, res) => {
    console.log(req);
    res.send('Hello world\n');
});

app.listen(PORT);

console.log(`Running on port: ${PORT}`);

