var express = require('express');
var app = express();
var fs = require("fs");
var walk    = require('walk');
var grunt = require('grunt');
var R2Builder = require("r2-builder")

// Nodejs libs.
var path = require('path');

app.use(express.bodyParser());

app.get('/r2apps', function(req, res) {
  var response = {profiles: "",apps: []};
  var r2apps = fs.readFileSync("./r2apps.json");
  response.profiles = JSON.parse(r2apps);
  
  var files   = [];

  var walker  = walk.walk('./app/apps', { followLinks: true });

  walker.on('file', function(root, stat, next) {
      // Add this file to the list of files
      if(stat.name.indexOf(".json") > 0 ){
        var filePath = root + '/' + stat.name;
        var fileContents = JSON.parse(fs.readFileSync(filePath));
        fileContents.path = root;
        files.push(fileContents);
      }
      next();
  });

  walker.on('end', function() {
    response.apps = files;
    res.type('application/json');
    res.send(response);
  });
  
});


app.post('/r2apps', function(req, res) {
  var file = fs.writeFileSync("./r2apps.json", JSON.stringify(req.body));
  res.send(200);
});

app.put('/r2apps', function(req,res){
  //if req.body.app.newApp
  grunt.file.delete("./app/apps/" + req.body.name);
  try{
    results = R2Builder.build( { "app": req.body , "component": req.body , "style": req.body , "layout": req.body } );
    grunt.file.write( "./app/apps/" + req.body.name + "/" + req.body.name + ".coffee" , results["app"]  );
    grunt.file.write( "./app/apps/" + req.body.name + "/component.json" , results["component"]  );
    grunt.file.write( "./app/apps/" + req.body.name + "/style.less" , results["style"]  );
    grunt.file.write( "./app/apps/" + req.body.name + "/layout.eco" , results["layout"]  );
  }
  catch(error){
    grunt.file.delete("./app/apps/" + req.body.name);
    res.status(501);
    res.send(error);
  }
  res.send(200);
});

module.exports = app;