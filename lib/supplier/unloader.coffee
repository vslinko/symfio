events = require "events"
async = require "async"


class Unloader extends events.EventEmitter
    constructor: ->
        @workers = []

    # Some plugins may register the worker which will be called during the
    # unloading process.
    register: (worker) ->
        @workers.unshift worker

    unload: (callback) ->
        @on "unloaded", callback if typeof callback is "function"

        async.series @workers, =>
            @emit "unloaded"


createInstance = ->
    new Unloader


module.exports = createInstance
module.exports.Unloader = Unloader
