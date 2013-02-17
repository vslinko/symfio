assert = require "assert"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Express plugin", ->
    supply = null

    beforeEach ->
        supply = supplier()
        supply.use supplier.plugins.express

    afterEach (callback) ->
        server = supply.get "server"
        try
            server.close callback
        catch err
            callback()

    it "should inject app, port, and server", (callback) ->
        supply.on "configured", ->
            assert.notEqual undefined, supply.get "app"
            assert.notEqual undefined, supply.get "port"
            assert.notEqual undefined, supply.get "server"
            callback()

    it "should start server after all plugins loaded", (callback) ->
        supply.on "configured", ->
            server = supply.get "server"
            server.on "listening", ->
                callback()
