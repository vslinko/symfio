module.exports = require if process.env.COVERAGE \
    then "./lib-cov/supplier"
    else "./lib/supplier"
