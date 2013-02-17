assert = require "assert"

fakePlugin = require "./mocks/fake_plugin"
supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Supplier", ->
    supply = null

    beforeEach ->
        supply = supplier()

    it "should extend event emitter", ->
        catched = false

        supply.on "event", ->
            catched = true

        supply.emit "event"
        assert.equal true, catched

    it "should contain configuration", ->
        supply.set "foo", "bar"
        assert.equal "bar", supply.get "foo"

    describe "use", ->
        it "should push plugin into array", (callback) ->
            plugin = ->
                callback()

            assert.equal 0, supply.plugins.length()
            supply.use plugin
            assert.equal 1, supply.plugins.length()

        it "should emit 'configured' after all plugins configured", (callback) ->
            configured = false

            supply.on "configured", ->
                configured = true

            plugin0 = fakePlugin()
            plugin1 = fakePlugin()

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

            plugin0 = fakePlugin()
            plugin1 = fakePlugin()

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

            plugin0 = fakePlugin()

            supply.use (supply, pluginCallback) ->
                supply.use plugin0.factory()
                pluginCallback()

                process.nextTick ->
                    assert.equal false, loaded
                    plugin0.loaded()
                    assert.equal true, loaded
                    callback()

    describe "wait", ->
        it "should run all listeners after value setted", (callback) ->
            length = 3
            listenersRunned = 0

            for i in [0...length]
                supply.wait "test", ->
                    listenersRunned += 1
                    callback() if listenersRunned == length

            process.nextTick ->
                supply.set "test", "mest"

        it "should run listener immediately if value exists", (callback) ->
            supply.set "test", "mest"
            supply.wait "test", ->
                callback()
