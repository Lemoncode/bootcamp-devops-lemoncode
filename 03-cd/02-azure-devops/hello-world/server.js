/* global __dirname */
/* global process */
var express = require('express');
var app = express();

app.get('/', function(req, res) {
	res.sendFile(__dirname + '/index.html');
});

app.listen(process.env.PORT, function() {
	console.log('Example app listening on port 3000!');
});
