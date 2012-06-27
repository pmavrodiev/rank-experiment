var PORT = 3100;
var APP_ROOT = __dirname + '/client/';
console.log("Root dir: " + APP_ROOT)

var express = require('express');

var app = express.createServer();

app.configure(function() {
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);  
  app.use(express.static(APP_ROOT));
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true}));
});


app.listen(PORT);
console.log("Listening on port: " + PORT);
