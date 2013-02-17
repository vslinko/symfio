assert = require "assert"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Assets plugin", ->
    supply = null

    beforeEach ->
        supply = supplier()
        supply.set "public directory", __dirname
        supply.use supplier.plugins.assets
        supply.use supplier.plugins.express

    afterEach (callback) ->
        server = supply.get "server"
        try
            server.close callback
        catch err
            callback()

    it "should connect four middlewares", (callback) ->
        connectedMiddlewaresLength = -1

        supply.wait "app", (app) ->
            connectedMiddlewaresLength = app.stack.length

        supply.on "loaded", ->
            app = supply.get "app"
            assert.equal connectedMiddlewaresLength + 4, app.stack.length
            callback()
