sequence = require "when/sequence"
events = require "events"


class Unloader extends events.EventEmitter
  constructor: ->
    @workers = []

  register: (worker) ->
    @workers.unshift worker

  unload: ->
    sequence(@workers).then =>
      @emit "unloaded"
      @workers = []


module.exports = ->
  new Unloader


module.exports.Unloader = Unloader
