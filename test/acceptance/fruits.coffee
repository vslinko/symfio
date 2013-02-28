example = require "../support/example"
require "should"


describe "Fruits example", ->
    test = unloader = null

    before (callback) ->
        example "fruits", ->
            [test, unloader] = arguments
            callback()

    after (callback) ->
        unloader.unload callback

    shoulds = [
        "load fixtures using fixtures plugin"
        "fetch fruits using mongoose plugin"
        "sort fruits using crud plugin"
        "and serve fruits using express plugin"
    ].join ", "

    it "should #{shoulds}", (callback) ->
        req = test.get "/fruits"
        req.end (err, res) ->
            res.should.have.status 200
            res.should.be.json
            res.body.should.be.array
            res.body.should.have.lengthOf 3
            res.body[0].name.should.equal "Orange"
            res.body[1].name.should.equal "Banana"
            res.body[2].name.should.equal "Apple"
            callback()
