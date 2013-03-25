events = require "events"
async = require "async"

class Loader extends events.EventEmitter
  constructor: (@container) ->
    @plugins = []

  use: (plugin) ->
    @plugins.push plugin

  load: ->
    pluginWorker = (plugin, callback) =>
      plugin @container, callback

    async.forEachSeries @plugins, pluginWorker, =>
      @emit "loaded"

module.exports = (container) ->
  new Loader container

module.exports.Loader = Loader
