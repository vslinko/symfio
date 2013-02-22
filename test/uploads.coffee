supertest = require "supertest"
assert = require "assert"
async = require "async"
path = require "path"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Uploads plugin", ->
    container = null
    test = null

    beforeEach (callback) ->
        container = supplier "example", __dirname
        loader = container.get "loader"
        loader.use supplier.plugins.assets
        loader.use supplier.plugins.express
        loader.use supplier.plugins.uploads

        loader.once "configured", ->
            app = container.get "app"
            test = supertest app
            callback()

    afterEach (callback) ->
        server = container.get "server"
        try
            server.close callback
        catch err
            callback()

    it "should send files and save it in filesystem", (callback) ->
        async.waterfall [
            (callback) ->
                req = test.post "/uploads"
                req.attach "file", "test/public/upload.png", "upload.png"
                req.end (err, res) ->
                    assert.equal 201, res.status
                    assert.ok res.header.location
                    callback null, res.header.location

            (location, callback) ->
                req = test.get location
                req.end (err, res) ->
                    assert.equal "image/png", res.type
                    callback()
        ], callback

    it "should return 400 http code when no file sent", (callback) ->
        req = test.post "/uploads"
        req.end (err, res) ->
            assert.equal 400, res.status
            callback()

    it "should show not found error", (callback) ->
        exit = process.exit
        process.exit = (code) ->
            assert.equal 1, code
            process.exit = exit
            callback()

        container = supplier "example", __dirname
        loader = container.get "loader"
        loader.use supplier.plugins.assets
        loader.use supplier.plugins.express
        loader.use supplier.plugins.uploads

        loader.once "injected", ->
            container.set "public directory", "/a"
            container.set "uploads directory", "/b"
