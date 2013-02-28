supertest = require "supertest"


module.exports = (example, callback) ->
    container = require "../../examples/#{example}"
    container.set "silent", true

    loader = container.get "loader"
    loader.load ->
        unloader = container.get "unloader"
        test = supertest container.get "app"

        callback test, unloader
