assert = require "assert"
path = require "path"
http = require "http"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Assets plugin", ->
    container = null
    loader = null

    beforeEach ->
        container = supplier()
        loader = container.get "loader"

        container.set "public directory", path.join __dirname, "public"
        loader.use supplier.plugins.assets
        loader.use supplier.plugins.express

    afterEach (callback) ->
        server = container.get "server"
        try
            server.close callback
        catch err
            callback()

    it "should connect four middlewares", (callback) ->
        connectedMiddlewaresLength = -1

        loader.once "injected", (app) ->
            app = container.get "app"
            connectedMiddlewaresLength = app.stack.length

        loader.once "configured", ->
            app = container.get "app"
            assert.equal connectedMiddlewaresLength + 4, app.stack.length
            callback()

    it "should import nib and responsive for stylus", (callback) ->
        expectedCSS = """
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

        loader.once "injected", ->
            server = container.get "server"
            server.on "listening", ->
                req = http.get "http://localhost:3000/style.css", (res) ->
                    css = ""

                    res.on "data", (data) ->
                        css += data.toString()

                    res.on "end", ->
                        assert.equal expectedCSS, css
                        callback()

                req.end()
