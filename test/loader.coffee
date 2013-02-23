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
            assert.equal 0, loader.plugins.length()
            loader.use ->
            assert.equal 1, loader.plugins.length()

        it "should emit 'injected' when all plugins injected", (callback) ->
            injected = false

            loader.once "injected", ->
                injected = true

            plugin0 = fakePlugin()
            plugin1 = fakePlugin()

            loader.use plugin0.factory()
            loader.use plugin1.factory()
            assert.equal false, injected

            process.nextTick ->
                plugin0.injected()
                assert.equal false, injected
                
                plugin1.injected()
                assert.equal true, injected
                
                callback()

        it "should emit 'configured' when all plugins configured", (callback) ->
            configured = false

            loader.once "configured", ->
                configured = true

            plugin0 = fakePlugin()
            plugin1 = fakePlugin()

            loader.use plugin0.factory()
            loader.use plugin1.factory()
            assert.equal false, configured

            process.nextTick ->
                plugin0.configured()
                assert.equal false, configured
                
                plugin1.configured()
                assert.equal true, configured

                callback()

        it "should emit 'loaded' when all plugins loaded", (callback) ->
            loaded = false

            loader.once "loaded", ->
                loaded = true

            plugin0 = fakePlugin()
            plugin1 = fakePlugin()

            loader.use plugin0.factory()
            loader.use plugin1.factory()
            assert.equal false, loaded

            process.nextTick ->
                plugin0.loaded()
                assert.equal false, loaded

                plugin1.loaded()
                assert.equal true, loaded

                callback()

        it "should inject container into plugin", (callback) ->
            loader.use (injectedContainer) ->
                assert.equal container, injectedContainer
                callback()

        it "should allow include one plugin in another", (callback) ->
            loaded = false

            loader.once "loaded", ->
                loaded = true

            plugin0 = fakePlugin()

            loader.use (injectedContainer, pluginCallback) ->
                loader.use plugin0.factory()
                pluginCallback()

                process.nextTick ->
                    assert.equal false, loaded
                    plugin0.loaded()
                    assert.equal true, loaded
                    callback()
