module.exports = (grunt) ->
    grunt.initConfig
        clean:
            coverage: ["lib-cov", "coverage.html"]
            docs: "docs"
        simplemocha:
            all:
                src: "test/*.coffee"
                options: reporter: "teamcity"
            acceptance:
                src: "test/acceptance/*.coffee"
                options: reporter: "spec"
            coverage:
                # Unit tests must be run after acceptance tests
                # because sinon stubs breaks mongoose
                src: ["test/acceptance/*.coffee", "test/*.coffee"]
                options: reporter: "html-file-cov"
            options: ignoreLeaks: true
        coffeeCoverage:
            all: src: "lib", dest: "lib-cov"
        coffeelint:
            examples: "examples/**/*.coffee"
            lib: "lib/**/*.coffee"
            test: "test/**/*.coffee"
            grunt: "Gruntfile.coffee"
            options: indentation: value: 4
        docco:
            lib: [
                "lib/supplier.coffee",
                "lib/supplier/!(plugins).coffee",
                "lib/supplier/plugins/*.coffee"
            ]
            options: output: "docs"

    grunt.registerTask "default", ["clean", "coverage", "lint", "docs"]
    grunt.registerTask "test", ["simplemocha:all", "simplemocha:acceptance"]
    grunt.registerTask "lint", "coffeelint"
    grunt.registerTask "docs", "docco"

    grunt.registerTask "coverage", ->
        process.env.COVERAGE = true
        grunt.task.run "coffeeCoverage"
        grunt.task.run "simplemocha:coverage"

    grunt.loadNpmTasks "grunt-contrib-clean"
    grunt.loadNpmTasks "grunt-simple-mocha"
    grunt.loadNpmTasks "grunt-coffee-coverage"
    grunt.loadNpmTasks "grunt-coffeelint"
    grunt.loadNpmTasks "grunt-docco"
