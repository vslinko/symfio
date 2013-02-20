# Plugins can share settings and variables using container.
class Container
    constructor: ->
        @container = {}

    set: (name, value) ->
        @container[name] = value

    get: (name) ->
        @container[name]


createInstance = ->
    new Container


module.exports = createInstance
module.exports.Container = Container
