sequence = require "when/sequence"
events = require "events"


class Loader extends events.EventEmitter
  constructor: (@container) ->
    @plugins = []

  use: (plugin) ->
    @plugins.push @container.inject plugin

  load: ->
    sequence(@plugins).then =>
      @emit "loaded"


module.exports = (container) ->
  new Loader container


module.exports.Loader = Loader
