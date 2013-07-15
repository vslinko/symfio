module.exports = (grunt) ->
  grunt.initConfig
    simplemocha:
      symfio: "test/symfio.coffee"
      coverage: src: "test/*.coffee", options: reporter: "travis-cov"
      coveralls: src: "test/*.coffee", options: reporter: "mocha-lcov-reporter"
      options: reporter: process.env.REPORTER or "spec"
    coffeelint:
      lib: "lib/**/*.coffee"
      test: "test/**/*.coffee"
      grunt: "Gruntfile.coffee"
    watch:
      test:
        files: ["lib/**/*.coffee", "test/**/*.coffee"]
        tasks: ["simplemocha", "coffeelint"]
    coffeeCoverage: lib: src: "lib", dest: "lib", options: path: "relative"
    clean: coffeeCoverage: "lib/**/*.js"

  grunt.loadNpmTasks "grunt-simple-mocha"
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-coffee-coverage"
  grunt.loadNpmTasks "grunt-contrib-clean"

  grunt.registerTask "default", [
    "coffeeCoverage:lib"
    "simplemocha:symfio"
    "clean:coffeeCoverage"
    "coffeelint"
    "simplemocha:coverage"
  ]
 
  grunt.registerTask "coveralls", [
    "coffeeCoverage:lib"
    "simplemocha:coveralls"
    "clean:coffeeCoverage"
  ]
