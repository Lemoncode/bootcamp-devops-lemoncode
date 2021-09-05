//Módulos
const express = require('express'),
    app = express(),
    mongodb = require('mongodb');

app.set('view engine', 'ejs');

app.get('/', async (req, res) => {

    //Recuperar topics de mongodb
    const client = await new mongodb.MongoClient('mongodb://localhost:27017').connect();

    const db = client.db('TopicstoreDb');

    const topics = await db.collection('Topics').find().toArray();

    console.log(`Topics: ${topics.length}`);
    console.log(topics);

    res.render('index', { topics });

});

app.listen(3000, () => {
    console.log('Server running on port 3000');
});