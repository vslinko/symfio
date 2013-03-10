module.exports = require if process.env.COVERAGE \
  then "./lib-cov/symfio"
  else "./lib/symfio"
