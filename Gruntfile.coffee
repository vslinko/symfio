module.exports = (grunt) ->
  grunt.initConfig
    clean:
      coverage: ["lib-cov", "coverage.html"]
      docs: "docs"
    simplemocha:
      all: "test/*.coffee"
      options: reporter: process.env.REPORTER or "spec"
    coffeeCoverage:
      lib: src: "lib", dest: "lib-cov"
    coffeelint:
      lib: "lib/**/*.coffee"
      test: "test/**/*.coffee"
      grunt: "Gruntfile.coffee"
    docco:
      lib: [
        "lib/symfio.coffee"
        "lib/symfio/!(test).coffee"
      ]
      options: output: "docs"

  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-simple-mocha"
  grunt.loadNpmTasks "grunt-coffee-coverage"
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks "grunt-docco"

  grunt.registerTask "default", [
    "clean"
    "coverage"
    "coffeelint"
    "docco"
  ]

  grunt.registerTask "coverage", ->
    process.env.COVERAGE = true

    grunt.config.set "simplemocha.options.reporter", "html-file-cov"

    grunt.task.run "coffeeCoverage"
    grunt.task.run "simplemocha"
