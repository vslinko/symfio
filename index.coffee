if process.env.SYMFIO_COVERAGE
  module.exports = require "./lib-cov"
else
  module.exports = require "./lib"
