symfio = require ".."
sinon = require "sinon"
chai = require "chai"


chai.use require "chai-as-promised"
chai.use require "sinon-chai"
chai.should()


describe "symfio()", ->
  it "should return configured container", (callback) ->
    container = symfio "test", __dirname

    container.get([
      "name"
      "applicationDirectory"
    ]).then (dependencies) ->
      dependencies[0].should.equal "test"
      dependencies[1].should.equal __dirname
    .should.notify callback

  describe "Symfio", ->
    describe "#use()", ->
      it "should add plugin to queue", ->
        container = new symfio.Symfio
        container.plugins.should.have.length 0

        container.use ->
        container.plugins.should.have.length 1

    describe "#load()", ->
      it "should load plugins", (callback) ->
        container = new symfio.Symfio
        plugin = sinon.spy()
        plugin.displayName = "function () {}"

        container.use plugin

        container.load().then ->
          plugin.should.have.been.calledOnce
        .should.notify callback

      it "should emit 'loaded' event after all plugins is loaded", (callback) ->
        listener = sinon.spy()
        container = new symfio.Symfio

        container.use ->
        container.once "loaded", listener

        container.load().then ->
          listener.should.have.been.calledOnce
        .should.notify callback

      it "should inject dependencies to plugin as first argument", (callback) ->
        container = new symfio.Symfio
        plugin = sinon.spy()
        plugin.displayName = "function (container) {}"

        container.use plugin

        container.load().then ->
          plugin.should.have.been.calledOnce
          plugin.should.have.been.calledWith container
        .should.notify callback
