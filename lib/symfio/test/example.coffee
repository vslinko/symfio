supertest = require "supertest"


class ExampleTest
  constructor: (@container) ->
    @container.set "silent", true

  before: ->
    load = (callback) =>
      loader = @container.get "loader"
      loader.load =>
        @test = supertest @container.get "app"
        callback()

    (callback) ->
      @timeout 10000
      load callback

  after: ->
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
