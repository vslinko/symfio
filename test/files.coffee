request = require "supertest"
assert = require "assert"
path = require "path"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Files plugin", ->
    container = null

    beforeEach (callback) ->
        container = supplier "example", __dirname
        loader = container.get "loader"
        loader.use supplier.plugins.assets
        loader.use supplier.plugins.express
        loader.use supplier.plugins.files

        loader.once "configured", ->
            callback()

    afterEach (callback) ->
        server = container.get "server"
        try
            server.close callback
        catch err
            callback()

    it "should send files and save it in filesystem", (callback) ->
        app = container.get "app"
        request(app)
            .post("/upload")
            .attach("file", "test/public/upload.png", "upload.png")
            .attach("second_file", "test/public/upload.png", "upload.png")
            .end (err, res) ->
                assert.ok res.header.location?
                
                request(app)
                    .get(res.header.location)
                    .end (err, res) ->
                        assert.equal "image/png", res.type
                        callback()

    it "should send without file with error", (callback) ->
        app = container.get "app"
        request(app)
            .post("/upload")
            .end (err, res) ->
                assert.equal 400, res.status
                callback()

    it "should show not found error", (callback) ->
        container = supplier "example", __dirname
        loader = container.get "loader"
        loader.use supplier.plugins.assets
        loader.use supplier.plugins.express
        loader.use supplier.plugins.files

        loader.once "injected", ->
            container.set "upload directory", "/tmp"

        loader.once "configured", ->
            app = container.get "app"
            request(app)
                .post("/upload")
                .end (err, res) ->
                    assert.equal 404, res.status
                    callback()
