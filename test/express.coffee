assert = require "assert"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Express plugin", ->
    container = null
    loader = null

    beforeEach ->
        container = supplier()
        loader = container.get "loader"

        loader.use supplier.plugins.express

    afterEach (callback) ->
        server = container.get "server"
        try
            server.close callback
        catch err
            callback()

    it "should inject app, port, and server", (callback) ->
        loader.once "injected", ->
            assert.ok container.get "app"
            assert.ok container.get "port"
            assert.ok container.get "server"
            callback()

    it "should start server after all plugins loaded", (callback) ->
        loader.once "injected", ->
            server = container.get "server"
            server.on "listening", ->
                callback()

    hasMiddleware = (name) ->
        app = container.get "app"
        for middleware in app.stack
            if middleware.handle.name is name
                return true
        false

    it "should use bodyParser", (callback) ->
        loader.once "configured", ->
            assert.ok hasMiddleware "bodyParser"
            callback()

    it "should use errorHandler in development environment", (callback) ->
        nodeEnv = process.env.NODE_ENV
        process.env.NODE_ENV = "development"
        loader.once "configured", ->
            assert.ok hasMiddleware "errorHandler"
            process.env.NODE_ENV = nodeEnv
            callback()
