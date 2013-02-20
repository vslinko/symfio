class FakePlugin
    factory: ->
        (stack, callback) =>
            @stack = stack
            @callback = callback

    injected: ->
        @callback.injected()

    configured: ->
        @callback.configured()

    loaded: ->
        @callback.loaded()


module.exports = ->
    new FakePlugin
