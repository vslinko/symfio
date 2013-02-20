assert = require "assert"
path = require "path"
http = require "http"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Assets plugin", ->
    supply = null

    beforeEach ->
        supply = supplier()
        supply.set "public directory", path.join __dirname, "public"
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

        supply.once "injected", (app) ->
            app = supply.get "app"
            connectedMiddlewaresLength = app.stack.length

        supply.once "configured", ->
            app = supply.get "app"
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

        supply.once "injected", ->
            server = supply.get "server"
            server.on "listening", ->
                req = http.get "http://localhost:3000/style.css", (res) ->
                    css = ""

                    res.on "data", (data) ->
                        css += data.toString()

                    res.on "end", ->
                        assert.equal expectedCSS, css
                        callback()

                req.end()
