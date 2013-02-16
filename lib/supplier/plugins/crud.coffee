crud = require "rithis-crud"


module.exports = (supply, callback) ->
    supply.set "crud", crud
    callback()
