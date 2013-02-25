assert = require "assert"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Unloader", ->
    unloader = null

    beforeEach ->
        unloader = new supplier.unloader.Unloader

    it "should extend event emitter", (callback) ->
        unloader.once "event", callback
        unloader.emit "event"

    describe "register", ->
        it "should register worker", ->
            assert.equal 0, unloader.workers.length
            unloader.register ->
            assert.equal 1, unloader.workers.length

    describe "unload", ->
        it "should run workers", (callback) ->
            unloader.register (unloaderCallback) ->
                unloaderCallback()
                callback()

            unloader.unload()

        it "should emit 'unloaded'", (callback) ->
            unloaded = false
            
            unloader.register (unloaderCallback) ->
                assert.equal false, unloaded
                unloaderCallback()
                assert.equal true, unloaded
                callback()

            unloader.on "unloaded", ->
                unloaded = true

            unloader.unload()

        it "should register callback", (callback) ->
            unloader.register (callback) ->
                callback()
            
            unloader.unload callback
