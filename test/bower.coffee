assert = require "assert"
async = require "async"
path = require "path"
fs = require "fs.extra"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Bower plugin", ->
    container = null
    loader = null
    publicDirectory = __dirname
    componentsDirectory = path.join publicDirectory, "components"

    this.timeout 0

    beforeEach (callback) ->
        fs.rmrf componentsDirectory, ->
            container = supplier()
            loader = container.get "loader"

            container.set "public directory", publicDirectory
            container.set "components", ["jquery#~1.9"]
            loader.use supplier.plugins.bower
            callback()

    afterEach (callback) ->
        fs.rmrf componentsDirectory, ->
            callback()

    it "should run bower one time in hour", (callback) ->
        async.series [
            (callback) ->
                loader.once "loaded", ->
                    jqueryDirectory = path.join componentsDirectory, "jquery"
                    fs.stat jqueryDirectory, (err, stats) ->
                        assert.ok stats.isDirectory()
                        callback()

            (callback) ->
                container = supplier()
                loader = container.get "loader"
                
                container.set "public directory", publicDirectory
                container.set "components", ["jquery#~1.9", "bootstrap"]
                loader.use supplier.plugins.bower

                loader.once "loaded", ->
                    bootstrapDirectory = path.join componentsDirectory, "bootstrap"
                    fs.stat bootstrapDirectory, (err, stats) ->
                        assert.equal 34, err.errno
                        callback()
        ], callback

    it "should output bower output", (callback) ->
        container.set "silent", false

        message = ""
        write = process.stdout.write
        process.stdout.write = (data) ->
            message += data.toString()

        loader.once "loaded", ->
            assert.ok message.indexOf("bower") >= 0
            process.stdout.write = write
            callback()
