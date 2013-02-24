# Plugins can share settings and variables using container.
events = require "events"


class Container extends events.EventEmitter
    constructor: ->
        @container = {}

    set: (name, value) ->
        previousValue = @container[name]
        @container[name] = value
        @emit "changed #{name}", value, previousValue

    get: (name) ->
        @container[name]


createInstance = ->
    new Container


module.exports = createInstance
module.exports.Container = Container
