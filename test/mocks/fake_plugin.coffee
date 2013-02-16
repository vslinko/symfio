class FakePlugin
    factory: ->
        plugin = (stack, callback) ->
            @stack = stack
            @callback = callback

        plugin.bind @

    configured: ->
        @callback.configured()

    loaded: ->
        @callback.loaded()


module.exports = FakePlugin
