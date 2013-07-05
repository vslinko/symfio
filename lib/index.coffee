kantaina = require "kantaina"
sequence = require "when/sequence"


logger =
  silly: ->
  debug: ->
  verbose: ->
  info: ->
  warn: ->
  error: ->


class Symfio extends kantaina.Container
  constructor: (name, applicationDirectory) ->
    super()
    @set "name", name
    @set "applicationDirectory", applicationDirectory
    @set "env", process.env.NODE_ENV or "development"
    @set "logger", logger

  injectAll: (plugins) ->
    sequence plugins.map (plugin) =>
      @inject.bind @, plugin


module.exports = (name, applicationDirectory) ->
  new Symfio name, applicationDirectory

module.exports.Symfio = Symfio
