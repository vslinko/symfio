assert = require "assert"
stream = require "stream"
colors = require "colors"

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

    catchOutput = (wrappedFunction) ->
        message = ""

        write = process.stdout.write
        process.stdout.write = (data) ->
            message += data.toString()

        wrappedFunction()

        process.stdout.write = write
        message

    describe "info", ->
        it "should output message", ->
            supply.set "silent", false
            
            output = catchOutput ->
                supply.info "hello", "world"
            assert.equal "supplier #{"hello".cyan} #{"world".grey}\n", output

        it "should output name", ->
            supply.set "silent", false
            supply.set "name", "test"

            output = catchOutput ->
                supply.info "hello", "world"
            assert.equal "test #{"hello".cyan} #{"world".grey}\n", output

            output = catchOutput ->
                supply.info "hello", "world", "mest"
            assert.equal "mest #{"hello".cyan} #{"world".grey}\n", output

        it "should not output message if silent", ->
            supply.set "silent", true

            output = catchOutput ->
                supply.info "hello", "world"
            assert.equal "", output

        it "should output numbers", ->
            supply.set "silent", false

            output = catchOutput ->
                supply.info 1, 2, 3
            assert.equal "3 #{"1".cyan} #{"2".grey}\n", output

    describe "warn", ->
        it "should output message", ->
            supply.set "silent", false

            output = catchOutput ->
                supply.warn "hello world"
            assert.equal "supplier #{"warn".yellow} #{"hello world".grey}\n", output

    describe "error", ->
        it "should output message and terminate application", ->
            supply.set "silent", false
            exitCode = 0

            exit = process.exit
            process.exit = (code) ->
                exitCode = code

            output = catchOutput ->
                supply.error 123, "hello world"
            assert.equal "supplier #{"error".red} #{"hello world".grey}\n", output
            assert.equal 123, exitCode

            process.exit = exit
