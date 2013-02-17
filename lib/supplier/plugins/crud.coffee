crud = require "rithis-crud"


module.exports = (supply, callback) ->
    supply.log "configuring", "crud"
    supply.set "crud", crud
    callback()
