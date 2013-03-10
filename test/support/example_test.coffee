supertest = require "supertest"

class ExampleTest
  constructor: (example) ->
    @container = require "../../examples/#{example}"
    @container.set "silent", true

  loader: ->
    load = (callback) =>
      loader = @container.get "loader"
      loader.load =>
        @test = supertest @container.get "app"
        callback()

    (callback) ->
      @timeout 10000
      load callback

  unloader: ->
    unload = (callback) =>
      unloader = @container.get "unloader"
      unloader.unload callback

    (callback) ->
      @timeout 10000
      unload callback

  wrap: (test) ->
    (callback) =>
      test.call @test, callback

module.exports = (example) ->
  new ExampleTest example
