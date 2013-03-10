# Just provide CRUD module.
#
#     symfio = require "symfio"
#     container = symfio "example", __dirname
#     loader = container.get "loader"
#     loader.use symfio.plugins.crud
#     loader.load()
crud = require "rithis-crud"


#### Provides:
#
# * __crud__ — CRUD module.
module.exports = (container, callback) ->
  logger = container.get "logger"

  logger.info "loading plugin", "crud"
  container.set "crud", crud

  callback()
