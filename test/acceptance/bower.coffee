example = require "../support/example"
require "should"


describe "Bower example", ->
    test = unloader = null

    before (callback) ->
        this.timeout 10000

        example "bower", ->
            [test, unloader] = arguments
            callback()

    after (callback) ->
        unloader.unload callback

    it "should install components", (callback) ->
        req = test.get "/components/jquery/jquery.js"
        req.end (err, res) ->
            res.should.have.status 200
            res.text.should.include "jQuery"
            callback()
