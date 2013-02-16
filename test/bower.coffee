assert = require "assert"
path = require "path"
fs = require "fs.extra"

supplier = require "../lib/supplier"


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

    it "should run bower", (callback) ->
        supply.on "loaded", ->
            jqueryDirectory = path.join componentsDirectory, "jquery"
            fs.stat componentsDirectory, (err, stats) ->
                assert.equal true, stats.isDirectory()
                callback()
