fakePlugin = require "./support/fake_plugin"
supplier = require ".."
require "should"


describe "Loader", ->
    container = null
    loader = null

    beforeEach ->
        container = new supplier.container.Container
        loader = new supplier.loader.Loader container

    it "should push plugin into array", ->
        loader.plugins.length.should.equal 0
        loader.use ->
        loader.plugins.length.should.equal 1

    it "should emit 'loaded' when all plugins loaded", (callback) ->
        loaded = false

        loader.once "loaded", ->
            loaded = true

        plugin0 = fakePlugin()
        plugin1 = fakePlugin()

        loader.use plugin0.factory()
        loader.use plugin1.factory()
        loader.load()
        loaded.should.be.false

        process.nextTick ->
            plugin0.callback()
            loaded.should.be.false

            plugin1.callback()
            loaded.should.be.true

            callback()

    it "should inject container into plugin", (callback) ->
        loader.use (injectedContainer) ->
            injectedContainer.should.equal container
            callback()

        loader.load()
