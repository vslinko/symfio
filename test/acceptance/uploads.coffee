example = require "../support/example"
require "should"


describe "Uploads example", ->
    test = unloader = null

    before (callback) ->
        example "uploads", ->
            [test, unloader] = arguments
            callback()

    after (callback) ->
        unloader.unload callback

    it "should receive file", (callback) ->
        req = test.post "/uploads"
        req.attach "file", __filename
        req.end (err, res) ->
            res.should.have.status 201
            res.should.have.header "Location"

            req = test.get res.headers.location
            req.end (err, res) ->
                res.should.have.status 200
                res.text.should.include "Super Unique Message"

                callback()
