class Helper
   
  @randomChars: (len) ->
    chars = '';

    while (chars.length < len) 
      chars += Math.random().toString(36).substring(2);

    return chars.substring(0, len);

module.exports = (grunt) ->

  orgId = "00DZ0000000orOaMAI"

  apiServer = "http://quiet-atoll-3343.herokuapp.com"

  grunt.initConfig
    
    clean:
      r2: ["public/**/*.js"]
      test: ['test/unit/*.js','test/functional/*.js','test/integration/*.js']
      testUnit: ['test/unit/*.html']

    copy: 
      main: 
        files:
           [ {expand: true, src: ['./images/**'], dest: './public'} ]

    less:
      development:
        files:
          "./public/r2.css" : "./css/index.less"


    threevot_compiler: {
      apps:{
        parts: "./r2apps.json",
        lessVariables: "./css/base/variables.less",
        organizationId: orgId,
        destination: "./public"
      }
      
      components:{
        parts: "./r2stage.json",
        lessVariables: "./css/base/variables.less",
        organizationId: orgId,
        destination: "./public"
      }
    },



    coffee:
      unit:
        expand: true,
        flatten: true,
        cwd: './test/unit/src/',
        src: ['**/*.coffee'],
        dest: './test/unit/',
        ext: '.js'        

      functional:
        expand: true,
        flatten: true,
        cwd: './test/functional_src/',
        src: ['**/*.coffee'],
        dest: './test/functional/',
        ext: '.js'

      integration:
        expand: true,
        flatten: true,
        cwd: './test/integration_src/',
        src: ['**/*.coffee'],
        dest: './test/integration/',
        ext: '.js'

    mochaTest:
      unit:
        options:
          reporter: 'spec'
        src: ['test/unit/*.js']
        
      functional:
        options:
          reporter: 'spec'
        src: ['test/functional/*.js']

      integration:
        options:
          reporter: 'spec'
        src: ['test/integration/*.js']


    mocha: 
      test:
        src: ['./test/unit/*.html']
        options:
          log: true
          run: true
          reporter: "Spec"
          mocha:
            globals: ["jQuery*","RSpine","exports"]
            ignoreLeaks: false

    threevot_tester: 
      allTest: 
        options:
          testScripts: ["./node_modules/chai/chai.js", "./node_modules/mocha/mocha.js" ]
          testStyles: ["./node_modules/mocha/mocha.css"]
          init: "chai.should();"
          lessVariables: ""
          destination: "./test/unit"
          template: "./test/unit/template.eco"
        src: "./app/**/test.json"


    watch:
      css:
        files: ["./css/*.less","./css/**/*.less"]
        tasks: ["less"]

      apps:
        files: ["./app/**/*.coffee" ,"./app/**/*.eco","./app/**/*.jeco","./app/**/*.less"]
        tasks: ["clean:r2","grunt_r2_compiler"]

      views:
        files: ["./views/*.jade","./views/**/*.jade"]
        tasks: ["jade"]

    jade:
      production:
        files:
          "./public/index.html": ["./views/index.jade"]
          "./public/login.html": ["./views/login.jade"]
        options: 
          data: 
            path: ""
            apiServer: apiServer
            app_url: "http://edge.3vot.com"

      dev:
        files:
          "./public/index.html": ["./views/index.jade"]
          "./public/login.html": ["./views/login.jade"]

        options:
          data:
            path: ""
            apiServer: apiServer
            app_url: "http://localhost:7770"

      test: 
        files:
          "./public/index.html": ["./views/index.jade"]
          "./public/login.html": ["./views/login.jade"]

        options:
          data:
            path: ""
            apiServer: apiServer
            app_url: "http://localhost:7770"

    express:
      all: 
        options:
          port: '7770',
          hostname: "0.0.0.0",
          bases: ['./public'],
          server: './server/main',
          livereload: true
    s3:
      options: 
        bucket: "edge.3vot.com",
        access: 'public-read',
        key: 'AKIAIHNBUFKPBA2LINFQ',
        secret: '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'

      test:
        options:
          encodePaths: true,
          maxOperations: 20

        upload: 
          [
             { src: './public/*.*', dest: "", gzip: true, access: 'public-read', headers: "Cache-Control": "max-age=0" }
             { src: './public/images/*.*', dest: "images", gzip: false, access: 'public-read', headers: "Cache-Control": "max-age=500" }
             { src: './public/' + orgId  + '/*.*', dest: orgId , gzip: false, access: 'public-read', headers: "Cache-Control": "max-age=0" }
          ]
          
          
          
    jasmine: 
      pivotal: 
        options: 
          specs: 'test/unit/*.js'
          keepRunner: true

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-express');


  grunt.loadNpmTasks('grunt-threevot-compiler');
  grunt.loadNpmTasks('grunt-threevot-tester');

  grunt.loadNpmTasks('grunt-mocha');
  grunt.loadNpmTasks('grunt-mocha-test');
  grunt.loadNpmTasks('grunt-contrib-jade');
  grunt.loadNpmTasks('grunt-s3');  


  grunt.registerTask("newTest" , ['clean:testUnit', 'threevot_tester', 'mocha'] )

  grunt.registerTask('test', ["copy","clean:test",'coffee',"jade:test","threevot_compiler","mochaTest"]);   

  grunt.registerTask('test_unit', ["clean:test",'coffee',"mochaTest:unit"]); 

  grunt.registerTask('test_functional', ["copy","clean:test",'coffee',"jade:test","threevot_compiler","mochaTest:functional"]); 

  grunt.registerTask('test_integration', ["copy","clean:test",'coffee',"jade:test","grunt-threevot_compiler","mochaTest:integration"]); 

  grunt.registerTask('build', ["copy",'coffee' , "test" , "threevot_compiler" , "jade:production","s3"]);   

  grunt.registerTask('server', ["clean","copy","threevot_compiler","less","jade:dev" , 'express','watch']);

  
  grunt.registerTask('default', ["copy",'clean','coffee' , 'mochaTest']);