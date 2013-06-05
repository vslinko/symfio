kantaina = require "kantaina"
symfio = require "../index"
sinon = require "sinon"
chai = require "chai"


describe "symfio.loader()", ->
  chai.use require "chai-as-promised"
  chai.use require "sinon-chai"
  chai.should()

  describe "Loader", ->
    describe "#use()", ->
      it "should add plugin to queue", ->
        loader = new symfio.loader.Loader kantaina()
        loader.plugins.should.have.length 0
        loader.use ->
        loader.plugins.should.have.length 1

    describe "#load()", ->
      it "should load plugins", (callback) ->
        loader = new symfio.loader.Loader kantaina()
        plugin = sinon.spy()
        plugin.displayName = "function () {}"
        loader.use plugin
        loader.load().then ->
          plugin.should.have.been.calledOnce
        .should.notify callback

      it "should emit 'loaded' event after all plugins is loaded", (callback) ->
        listener = sinon.spy()
        loader = new symfio.loader.Loader kantaina()
        loader.use ->
        loader.once "loaded", listener
        loader.load().then ->
          listener.should.have.been.calledOnce
        .should.notify callback

      it "should inject dependencies to plugin as first argument", (callback) ->
        container = kantaina()
        loader = new symfio.loader.Loader container
        plugin = sinon.spy()
        plugin.displayName = "function (container) {}"

        loader.use plugin
        loader.load().then ->
          plugin.should.have.been.calledOnce
          plugin.should.have.been.calledWith container
        .should.notify callback
