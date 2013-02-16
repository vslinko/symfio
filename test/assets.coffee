assert = require "assert"

supplier = require "../lib/supplier"


describe "Assets plugin", ->
    supply = null

    beforeEach ->
        supply = supplier __dirname, "test"
        supply.use supplier.plugins.assets
        supply.use supplier.plugins.express

    afterEach (callback) ->
        server = supply.get "server"
        try
            server.close callback
        catch err
            callback()

    it "should inject 'publicDirectory'", (callback) ->
        supply.on "configured", ->
            assert.notEqual undefined, supply.get "publicDirectory"
            callback()

    it "should connect four middlewares", (callback) ->
        connectedMiddlewaresLength = -1

        supply.wait "app", (app) ->
            connectedMiddlewaresLength = app.stack.length

        supply.on "loaded", ->
            app = supply.get "app"
            assert.equal connectedMiddlewaresLength + 4, app.stack.length
            callback()
