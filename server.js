// modules
//TEST LINE FOR PULL
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var methodOverride = require ('method-override');
// To get R running
// var http = require('http');
// var exec = require('child_process').exec;
// var server = express.createServer();


// config
var db = require('./config/database');
var port = 8080;

// File Upload
var fs = require('fs-extra');
var path = require('path');
var busboy = require('connect-busboy');

// File Upload
// middleware
app.use(busboy());
// for static file storage
app.use(express.static(path.join(__dirname, 'public')));

app.route('/upload')
	.post(function (req, res, next) {
		var fstream;
		req.pipe(req.busboy);
		req.busboy.on('file', function(fieldname, file, filename) {
			console.log("Uploading: " + filename);

		var xtsn = filename.substring(filename.lastIndexOf("."), filename.length);
	    	var ws = fs.createWriteStream('public/data/bbqpizza' + xtsn);
	    	file.pipe(ws);
	    	res.redirect(req.url +":80")
		});
	});


// connect to our mongoDB database 
// (uncomment after you enter in your own credentials in config/db.js)
// mongoose.connect(db.url); 
//mongoose.connect(configDB.url); // connect to our database

// get all data/stuff of the body (POST) parameters
// parse application/json 
app.use(bodyParser.json()); 
// parse application/vnd.api+json as json
app.use(bodyParser.json({ type: 'application/vnd.api+json' })); 
// parse application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: true })); 
// override with the X-HTTP-Method-Override header in the request. simulate DELETE/PUT
app.use(methodOverride('X-HTTP-Method-Override')); 
// set the static files location /public/img will be /img for users
// app.use(express.static(__dirname + '/public')); 

// routes ==================================================
require('./app/routes')(app); // configure our routes
// start app ===============================================
// startup our app at http://localhost:8080
app.listen(port);               
// shoutout to the user                     
console.log('Magic happens on port ' + port);
// expose app           
exports = module.exports = app;


// Get R running
// server.configure(function(){    
//     server.use(express.static(__dirname + '/public'));
// });
// server.get('/', function(req, res) {
//     res.writeHead(200, {'Content-Type': 'text/html'});
//     res.write('R graph<br>');
//     process.env.R_WEB_DIR = process.cwd() + '/public';
//     var child = exec('Rscript script/xyplot.R', function(error, stdout, stderr) {
//         console.log('stdout: ' + stdout);
//         console.log('stderr: ' + stderr);
//         if (error !== null) {
//             console.log('exec error: ' + error);
//         }
//         res.write('<img src="/xyplot.png"/>');
//         res.end('<br>end of R script');
//     });
// });

// server.listen(1337, "127.0.0.1");
// console.log('Server running at http://127.0.0.1:1337/');
