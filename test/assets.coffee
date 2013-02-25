supertest = require "supertest"
cleaner = require "./utils/cleaner"
assert = require "assert"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Assets plugin", ->
    connectedMiddlewaresLength = null
    container = null
    loader = null
    server = null
    test = null
    app = null

    beforeEach (callback) ->
        container = supplier "test", __dirname
        container.set "silent", true
        loader = container.get "loader"
        loader.use supplier.plugins.assets
        loader.use supplier.plugins.express

        loader.once "injected", ->
            server = container.get "server"
            app = container.get "app"

            connectedMiddlewaresLength = app.stack.length
            test = supertest app
            callback()

    afterEach (callback) ->
        cleaner container, [
            cleaner.assets
        ], callback

    it "should connect four middlewares", (callback) ->
        loader.once "configured", ->
            assert.equal connectedMiddlewaresLength + 4, app.stack.length
            callback()

    it "should import nib and responsive for stylus", (callback) ->
        css = """
        .test {
          -webkit-border-radius: 5px;
          border-radius: 5px;
          width: 500px;
        }
        @media (max-width: 979px) {
          .test {
            width: 400px;
          }
        }
        @media (max-width: 767px) {
          .test {
            width: 300px;
          }
        }

        """

        req = test.get "/style.css"
        req.end (err, res) ->
            assert.equal 200, res.status
            assert.equal css, res.text
            callback()
