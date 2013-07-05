kantaina = require "kantaina"
w = require "when"


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
    w.map plugins, @inject.bind @


module.exports = (name, applicationDirectory) ->
  new Symfio name, applicationDirectory

module.exports.Symfio = Symfio
