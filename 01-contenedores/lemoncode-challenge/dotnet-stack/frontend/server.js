//Módulos
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
const express = require('express'),
    app = express();

const LOCAL = 'http://localhost:5000/api/topics';

app.set('view engine', 'ejs');

app.get('/', async (req, res) => {

    //Recuperar topics de la API
    const response = await fetch(process.env.API_URI || LOCAL);
    const topics = await response.json();

    res.render('index', { topics });

});

app.listen(3000, () => {
    console.log(`Server running on port 3000 with ${process.env.API_URI || LOCAL}`);
});