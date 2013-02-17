# Just provide CRUD module.
#
#     supplier = require "supplier"
#     supply = supplier()
#     supply.use supplier.plugins.crud
crud = require "rithis-crud"


#### Provides:
#
# * __crud__ — CRUD module.
module.exports = (supply, callback) ->
    supply.log "configuring", "crud"
    supply.set "crud", crud
    callback()
