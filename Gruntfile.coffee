module.exports = (grunt) ->
  grunt.initConfig
    clean:
      coverage: ["lib-cov", "coverage.html"]
    simplemocha:
      all: "test/*.coffee"
      options: reporter: process.env.REPORTER or "spec"
    coffeeCoverage:
      lib: src: "lib", dest: "lib-cov"
    coffeelint:
      lib: "lib/**/*.coffee"
      test: "test/**/*.coffee"
      grunt: "Gruntfile.coffee"

  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-simple-mocha"
  grunt.loadNpmTasks "grunt-coffee-coverage"
  grunt.loadNpmTasks "grunt-coffeelint"

  grunt.registerTask "default", [
    "clean"
    "coverage"
    "coffeelint"
  ]

  grunt.registerTask "coverage", ->
    process.env.SYMFIO_COVERAGE = true
    grunt.config.set "simplemocha.options.reporter", "html-file-cov"
    grunt.task.run "coffeeCoverage"
    grunt.task.run "simplemocha"
