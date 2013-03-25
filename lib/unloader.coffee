events = require "events"
async = require "async"

class Unloader extends events.EventEmitter
  constructor: ->
    @workers = []

  register: (worker) ->
    @workers.unshift worker

  unload: ->
    async.series @workers, =>
      @emit "unloaded"

module.exports = ->
  new Unloader

module.exports.Unloader = Unloader
