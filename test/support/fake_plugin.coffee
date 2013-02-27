class FakePlugin
    factory: ->
        (container, callback) =>
            @callback = callback

module.exports = ->
    new FakePlugin
