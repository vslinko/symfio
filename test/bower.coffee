assert = require "assert"
async = require "async"
path = require "path"
fs = require "fs.extra"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Bower plugin", ->
    supply = null
    publicDirectory = __dirname
    componentsDirectory = path.join publicDirectory, "components"

    this.timeout 0

    beforeEach (callback) ->
        fs.rmrf componentsDirectory, ->
            supply = supplier()
            supply.set "public directory", publicDirectory
            supply.set "components", ["jquery#~1.9"]
            supply.use supplier.plugins.bower
            callback()

    afterEach (callback) ->
        fs.rmrf componentsDirectory, ->
            callback()

    it "should run bower one time in hour", (callback) ->
        async.series [
            (callback) ->
                supply.on "loaded", ->
                    jqueryDirectory = path.join componentsDirectory, "jquery"
                    fs.stat jqueryDirectory, (err, stats) ->
                        assert.equal true, stats.isDirectory()
                        callback()

            (callback) ->
                supply = supplier()
                supply.set "public directory", publicDirectory
                supply.set "components", ["jquery#~1.9", "bootstrap"]
                supply.use supplier.plugins.bower
                supply.on "loaded", ->
                    bootstrapDirectory = path.join componentsDirectory, "bootstrap"
                    fs.stat bootstrapDirectory, (err, stats) ->
                        assert.equal 34, err.errno
                        callback()
        ], callback

    it "should output bower output", (callback) ->
        supply.set "silent", false

        message = ""
        write = process.stdout.write
        process.stdout.write = (data) ->
            message += data.toString()

        supply.on "loaded", ->
            assert.equal true, message.indexOf("bower") >= 0
            process.stdout.write = write
            callback()
