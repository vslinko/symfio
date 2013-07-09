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
  constructor: (@name, @applicationDirectory) ->
    super()
    @require "kantaina"
    @require "w", "when"

  require: (name, module = name) ->
    @unless name, ->
      require module

  injectAll: (plugins) ->
    w.map plugins, @inject.bind @

  clean: ->
    super()
    @set "name", @name
    @set "applicationDirectory", @applicationDirectory
    @set "env", process.env.NODE_ENV or "development"
    @set "logger", logger


module.exports = (name, applicationDirectory) ->
  new Symfio name, applicationDirectory

module.exports.Symfio = Symfio
