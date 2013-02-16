class FakePlugin
    factory: ->
        (stack, callback) =>
            @stack = stack
            @callback = callback

    configured: ->
        @callback.configured()

    loaded: ->
        @callback.loaded()


module.exports = ->
    new FakePlugin
