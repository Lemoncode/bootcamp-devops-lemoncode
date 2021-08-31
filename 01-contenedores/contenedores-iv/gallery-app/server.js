const express = require('express'),
    fs = require('fs'),
    path = require('path'),
    url = require('url'),
    app = express();

const PORT = 8080;
const imageDir = path.join(__dirname, 'images');

//static files
app.use(express.static(__dirname + '/public'));

app.get('/', function (req, res) {

    let query = url.parse(req.url, true).query;
    let image = query.image;

    if (typeof image === 'undefined') {
        getImages(imageDir, (err, files) => {

            if (files.length > 0) {

                let imageList = '<ul>';
                for (let i = 0; i < files.length; i++) {
                    imageList += `<li><a href="/?image=${files[i]}">${files[i]}</a></li>`;
                }
                imageList += '</ul>';
                res.writeHead(200, { 'Content-Type': 'text/html' });
                res.end(`<h1>Image Gallery</h1>${imageList}`);
            }
            else {
                res.writeHead(404, { 'Content-Type': 'text/html' });
                res.end(`<h1>Image Gallery</h1><img src="pulp-fiction-john-travolta.gif"/>`);
            }
        });
    }
    else {
        //read the image from the file system
        fs.readFile(path.join(imageDir, image), (err, content) => {
            if (err) {
                if (err.code == 'ENOENT') {
                    //page for the image not found
                    res.writeHead(200, { 'Content-Type': 'text/html' });
                    res.end('Sorry, requested image not found');
                }
                else {
                    //some server error
                    res.writeHead(500);
                    res.end(`Server Error: ${err.code}`);
                }
            }
            else {
                //ok, the image was found, send it
                res.writeHead(200, { 'Content-Type': 'image/jpg' });
                res.end(content);
            }
        });
    }

});

app.listen(PORT, function () {
    console.log(`Server running at http://127.0.0.1:${PORT}/`);
});

//get the list of jpg files in the image directory
function getImages(imageDir, callback) {
    const fileTypes = ['.jpg', '.jpeg', '.png'];
    let files = [];

    fs.readdir(imageDir, (err, list) => {
        console.log(`${list.length} files found`);
        for (let i = 0; i < list.length; i++) {
            if (fileTypes.includes(path.extname(list[i]))) {
                files.push(list[i]);
            }
        }
        callback(err, files);
    });
}