fakePlugin = require "./utils/fake_plugin"
assert = require "assert"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Loader", ->
    container = null
    loader = null

    beforeEach ->
        container = new supplier.container.Container
        loader = new supplier.loader.Loader container

    it "should extend event emitter", (callback) ->
        loader.once "event", callback
        loader.emit "event"

    describe "use", ->
        it "should push plugin into array", ->
            assert.equal 0, loader.plugins.length
            loader.use ->
            assert.equal 1, loader.plugins.length

        it "should emit 'loaded' when all plugins loaded", (callback) ->
            loaded = false

            loader.once "loaded", ->
                loaded = true

            plugin0 = fakePlugin()
            plugin1 = fakePlugin()

            loader.use plugin0.factory()
            loader.use plugin1.factory()
            loader.load()
            assert.equal false, loaded

            process.nextTick ->
                plugin0.callback()
                assert.equal false, loaded

                plugin1.callback()
                assert.equal true, loaded

                callback()

        it "should inject container into plugin", (callback) ->
            loader.use (injectedContainer) ->
                assert.equal container, injectedContainer
                callback()

            loader.load()
