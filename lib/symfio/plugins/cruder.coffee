# Just provide cruder module.
#
#     symfio = require "symfio"
#     container = symfio "example", __dirname
#     loader = container.get "loader"
#     loader.use symfio.plugins.cruder
#     loader.load()
cruder = require "cruder"


#### Provides:
#
# * __cruder__ — cruder module.
module.exports = (container, callback) ->
  logger = container.get "logger"

  logger.info "loading plugin", "cruder"
  container.set "cruder", cruder

  callback()
