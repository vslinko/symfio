sequence = require "when/sequence"
kantaina = require "kantaina"


class Symfio extends kantaina.Container
  constructor: ->
    super()
    @plugins = []

  use: (plugin) ->
    @plugins.push @inject plugin

  load: ->
    sequence(@plugins).then =>
      @emit "loaded"


module.exports = (name, applicationDirectory) ->
  symfio = new Symfio

  symfio.set "name", name
  symfio.set "applicationDirectory", applicationDirectory
  symfio.set "env", process.env.NODE_ENV or "development"
  symfio.set "logger",
    silly: ->
    debug: ->
    verbose: ->
    info: ->
    warn: ->
    error: ->

  symfio


module.exports.Symfio = Symfio
