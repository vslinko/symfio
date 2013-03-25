events = require "events"

class Container extends events.EventEmitter
  constructor: ->
    @container = {}

  set: (name, value) ->
    previousValue = @container[name]
    @container[name] = value
    @emit "changed #{name}", value, previousValue

  get: (name, defaultValue) ->
    return defaultValue if @container[name] is undefined
    @container[name]

module.exports = ->
  new Container

module.exports.Container = Container
