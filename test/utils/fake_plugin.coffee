class FakePlugin
    factory: ->
        (container, callback) =>
            @callback = callback

    injected: ->
        @callback.injected()

    configured: ->
        @callback.configured()

    loaded: ->
        @callback.loaded()


module.exports = ->
    new FakePlugin
