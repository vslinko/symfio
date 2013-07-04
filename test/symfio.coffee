symfio = require ".."
chai = require "chai"


describe "symfio()", ->
  chai.use require "chai-as-promised"
  chai.should()

  it "should return new symfio.Symfio()", ->
    container = symfio "test", __dirname
    container.should.be.instanceOf symfio.Symfio

  describe "Symfio", ->
    it "should return configured container", (callback) ->
      container = new symfio.Symfio "test", __dirname

      container.get([
        "name"
        "applicationDirectory"
        "env"
        "logger"
      ]).spread (name, applicationDirectory, env, logger) ->
        name.should.equal "test"
        applicationDirectory.should.equal __dirname
        env.should.equal "development"
        logger.should.be.a "object"
      .should.notify callback

    it "should use NODE_ENV as env", (callback) ->
      process.env.NODE_ENV = "production"
      container = new symfio.Symfio "test", __dirname

      container.get("env").then (env) ->
        env.should.equal "production"
      .should.notify callback

    describe "#injectAll()", ->
      it "should inject all plugins", (callback) ->
        pluginA = (container) ->
          container.set "a", 1

        pluginB = (container) ->
          container.set "b", (a) ->
            a + 1

        pluginC = (container) ->
          container.set "c", (a, b) ->
            a + b

        container = symfio "test", __dirname

        container.injectAll([
          pluginC
          pluginB
          pluginA
        ]).then ->
          container.get "c"
        .then (c) ->
          c.should.equal 3
        .should.notify callback
