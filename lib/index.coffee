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
  _require = require

  constructor: (@name = "symfio", @applicationDirectory = process.cwd()) ->
    super()

  require: (name, module = name) ->
    if typeof name is "function"
      _require = name
    else
      @unless name, (logger) ->
        logger.debug "require module", name: module
        _require module

  injectAll: (plugins) ->
    w.map plugins, @inject.bind @

  clean: ->
    super()
    @set "name", @name
    @set "applicationDirectory", @applicationDirectory
    @set "env", process.env.NODE_ENV or "development"
    @set "logger", logger
    @require "kantaina"
    @require "w", "when"


module.exports = (name, applicationDirectory) ->
  new Symfio name, applicationDirectory

module.exports.Symfio = Symfio
