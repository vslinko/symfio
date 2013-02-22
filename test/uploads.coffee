supertest = require "supertest"
cleaner = require "./utils/cleaner"
assert = require "assert"
async = require "async"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Uploads plugin", ->
    container = null
    loader = null

    beforeEach ->
        container = supplier "example", __dirname
        loader = container.get "loader"
        loader.use supplier.plugins.assets
        loader.use supplier.plugins.express
        loader.use supplier.plugins.uploads

    afterEach (callback) ->
        cleaner container, [
            cleaner.assets
            cleaner.express
            cleaner.uploads
        ], callback

    it "should send files and save it in filesystem", (callback) ->
        loader.once "injected", ->
            test = supertest container.get "app"

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
        loader.once "injected", ->
            test = supertest container.get "app"

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

        loader.once "injected", ->
            container.set "public directory", "/a"
            container.set "uploads directory", "/b"
