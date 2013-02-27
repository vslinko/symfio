supplier = require ".."
sinon = require "sinon"
require "should"


describe "Unloader", ->
    unloader = null

    beforeEach ->
        unloader = new supplier.unloader.Unloader

    it "should extend event emitter", (callback) ->
        unloader.once "event", callback
        unloader.emit "event"

    it "should register worker", ->
        unloader.workers.length.should.equal 0
        unloader.register ->
        unloader.workers.length.should.equal 1

    it "should run workers", (callback) ->
        unloader.register (unloaderCallback) ->
            unloaderCallback()
            callback()

        unloader.unload()

    it "should emit 'unloaded'", (callback) ->
        listener = sinon.spy()

        unloader.register (unloaderCallback) ->
            listener.called.should.be.false
            unloaderCallback()
            listener.called.should.be.true
            callback()

        unloader.on "unloaded", listener

        unloader.unload()

    it "should register callback", (callback) ->
        unloader.register (callback) ->
            callback()

        unloader.unload callback
