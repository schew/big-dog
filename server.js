// modules
//TEST LINE FOR PULL
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var methodOverride = require ('method-override');

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
			//Path to where it'll be uploaded
			fstream = fs.createWriteStream(__dirname + '/data/' + filename);

		    fstream.on('open', function(fd) {
		    	file.pipe(fstream);
		    }).on('close', function() {
				console.log("Upload Finished of " + filename);
				res.redirect('back');
			});;

			// file.pipe(fstream);
			// fstream.on('close', function() {
			// 	console.log("Upload Finished of " + filename);
			// 	res.redirect('back');
			// });
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