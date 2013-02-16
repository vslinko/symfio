assert = require "assert"

supplier = require "../lib/supplier"
FakePlugin = require "./mocks/fake_plugin"


describe "Supplier", ->
    supply = null

    beforeEach ->
        supply = supplier __dirname, "test"

    describe "constructor", ->
        it "should construct directory and name", ->
            assert.equal __dirname, supply.get "directory"
            assert.equal "test", supply.get "name"

    it "should be configurable", ->
        supply.set "foo", "bar"
        assert.equal "bar", supply.get "foo"

    describe "use", ->
        it "should push plugin into array", (callback) ->
            plugin = ->
                callback()

            assert.equal 0, supply.plugins.length()
            supply.use plugin
            assert.equal 1, supply.plugins.length()

    it "should extend event emitter", ->
        catched = false

        supply.on "event", ->
            catched = true

        supply.emit "event"
        assert.equal true, catched

    describe "run", ->
        it "should emit 'configured' after all plugins configured", (callback) ->
            configured = false

            supply.on "configured", ->
                configured = true

            plugin0 = new FakePlugin
            plugin1 = new FakePlugin

            supply.use plugin0.factory()
            supply.use plugin1.factory()

            assert.equal false, configured

            process.nextTick ->
                plugin0.configured()
                assert.equal false, configured
                plugin1.configured()

                assert.equal true, configured
                callback()

        it "should emit 'loaded' after all plugins loaded", (callback) ->
            loaded = false

            supply.on "loaded", ->
                loaded = true

            plugin0 = new FakePlugin
            plugin1 = new FakePlugin

            supply.use plugin0.factory()
            supply.use plugin1.factory()

            assert.equal false, loaded

            process.nextTick ->
                plugin0.loaded()
                assert.equal false, loaded
                plugin1.loaded()

                assert.equal true, loaded
                callback()

        it "should allow include one plugin in another", (callback) ->
            loaded = false

            supply.on "loaded", ->
                loaded = true

            plugin0 = new FakePlugin

            supply.use (supply, pluginCallback) ->
                supply.use plugin0.factory()
                pluginCallback()

                process.nextTick ->
                    assert.equal false, loaded
                    plugin0.loaded()
                    assert.equal true, loaded
                    callback()
